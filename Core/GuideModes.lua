local _,HP=...
function HP.CurrentGuideMap()
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
    for depth=1,8 do
        for _,id in ipairs(HP.guideOrder) do if HP.routes[id].mapID==map then return map end end
        local info=map and HP.Call(C_Map.GetMapInfo,map);local parent=info and info.parentMapID
        if not parent or parent==0 or parent==map then return map end
        map=parent
    end
    return map
end
function HP.SetGuideStyle(style)
    if style~='normal' and style~='speed' then return end
    HP.db.guideStyle=style;HP.db.selectedGuide=nil;HP.review=false;HP.resyncGuide=true;HP.abandonDismissed={};HP.normalDeferred={};HP.normalQuestFocus=nil;HP.UseGuide()
end
function HP.SpeedQuestIncluded(step,route)
    local list=route and HP.speedStarterQuests[route.chapterNumber]
    return not list or list[step.questID]==true
end
local score=HP.CandidateScore
function HP.CandidateScore(step)
    local value=score(step);if value==nil then return end
    if HP.db.guideStyle=='normal' and HP.Active(step.questID) then
        value=value-100000
        if HP.normalQuestFocus==step.questID then value=value-1000000 end
    end
    if HP.db.guideStyle=='speed' then
        if not HP.SpeedQuestIncluded(step,HP.route) then return end
        local q=HP.questData[step.questID] or {};local phase=HP.QuestStepPhase(step)
        if q.repeatable or q.questType==21 then return end
        local count=0;for _,goal in ipairs(q.goals or {}) do count=count+(goal.count or 1) end
        if phase.action=='objective' then value=value+count*.25 end
        if q.xp and q.xp>0 then value=value-math.min(15,q.xp/300) end
    end
    return value
end
local route=HP.Route
function HP.Route(race,build)
    HP.ResolveForeverMaps()
    if (HP.db.selectedGuide and HP.db.guideStyle~="normal") or not HP.db.guideStyle then return route(race,build) end
    local map=HP.CurrentGuideMap();local level=HP.character.level or 1
    if HP.db.guideStyle=='normal' then
        for _,id in ipairs(HP.guideOrder) do local r=HP.routes[id];if r.mapID==map then return id,r end end
    else
        if level<=12 then
            local id=({Orc='chapter_01',Troll='chapter_01',Tauren='chapter_02',Scourge='chapter_03'})[race]
            if id then return id,HP.routes[id] end
            if HP.routes.zone_16593 and HP.routes.zone_16593.mapID==map then return 'zone_16593',HP.routes.zone_16593 end
        end
        local first
        for _,chapter in ipairs(HP.chapterList) do
            if chapter.number>=4 and level>=chapter.minLevel and level<=chapter.maxLevel then
                local r=HP.routes[chapter.id];first=first or chapter.id
                if r and r.mapID==map then return chapter.id,r end
            end
        end
        if first then return first,HP.routes[first] end
    end
    return route(race,build)
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local events=CreateFrame('Frame',nil,UIParent);HP.guideModeEvents=events
    for _,event in ipairs({'PLAYER_LEVEL_UP','ZONE_CHANGED_NEW_AREA','PLAYER_REGEN_ENABLED'}) do pcall(events.RegisterEvent,events,event) end
    events:SetScript('OnEvent',function(_,event,level)
        if not HP.db.guideStyle or HP.db.selectedGuide then return end
        if HP.Call(InCombatLockdown)==true then HP.modeRoutePending=true;return end
        if event=='PLAYER_LEVEL_UP' and HP.Public(level) and type(level)=='number' then HP.levelFromEvent=level end
        if event~='PLAYER_REGEN_ENABLED' or HP.modeRoutePending then
            HP.modeRoutePending=false;HP.DetectCharacter();local id=HP.Route(HP.character.race,HP.character.build)
            if id~=HP.routeID then HP.UseGuide() end
        end
    end)
end

-- Only known current-zone quests can be suggested for manual cleanup.
function HP.GetAbandonQuest()
    if HP.db.guideStyle~='speed' or HP.db.mode=='quests' or HP.review or HP.demo or not HP.route then return end
    if not HP.speedQuestSet then
        HP.speedQuestSet={}
        for _,chapter in ipairs(HP.chapterList) do
            for _,step in ipairs(HP.routes[chapter.id] and HP.routes[chapter.id].steps or {}) do
                local q=HP.questData[step.questID]
                if q and HP.SpeedQuestIncluded(step,HP.routes[chapter.id]) and not (q.groupRecommended or q.repeatable or q.questType==1 or q.questType==21 or q.questType==62) then HP.speedQuestSet[step.questID]=true end
            end
        end
    end
    local zoneQuests={};local currentMap=HP.CurrentGuideMap()
    for _,id in ipairs(HP.guideOrder) do local route=HP.routes[id]
        if route.mapID==currentMap then for _,step in ipairs(route.steps) do zoneQuests[step.questID]=true end end
    end
    for _,quest in ipairs(HP.Quests()) do
        local q=HP.questData[quest.questID]
        local retained=HP.speedQuestSet[quest.questID]
        for _,step in ipairs(HP.route.steps) do if step.questID==quest.questID and HP.Applies(step) and HP.CandidateScore(step) then retained=true;break end end
        if q and HP.Active(quest.questID) and HP.Applies({questID=quest.questID,classes=q.classes,races=q.races,newForever=q.newForever}) and zoneQuests[quest.questID] and not q.classQuest and not q.classes and not q.navigationPending and not retained and not (HP.abandonDismissed and HP.abandonDismissed[quest.questID]) then return quest end
    end
end

function HP.ReconcileNormalQuestLog()
    if HP.db.guideStyle~='normal' or HP.db.mode=='quests' or HP.demo then return end
    local map=HP.CurrentGuideMap();local zoneRoute,id
    for _,candidateID in ipairs(HP.guideOrder) do local candidate=HP.routes[candidateID]
        if candidate.mapID==map then zoneRoute=candidate;id=candidateID;break end
    end
    if not zoneRoute then return end
    if HP.routeID~=id then
        HP.routeID=id;HP.route=zoneRoute;HP.review=false;HP.normalQuestFocus=nil
        HP.db.routes[id]=HP.db.routes[id] or {index=1,skipped={},revision=zoneRoute.revision}
        HP.state=HP.db.routes[id]
    end
    local route,state=HP.route,HP.state;local index={}
    for i,step in ipairs(route.steps) do if step.questID then index[step.questID]=i end end
    HP.normalLogQuests=HP.Quests()
    for _,quest in ipairs(HP.normalLogQuests) do
        local q=HP.questData[quest.questID];local relevant=index[quest.questID]~=nil
        if not relevant and q then
            for _,zone in ipairs(HP.zoneCatalog) do if zone.id==id and q.zoneID==zone.areaID then relevant=true;break end end
            for _,npcID in ipairs({q.start or 0,q.finish or 0}) do
                local npc=HP.npcData[npcID];if npc and npc.location and npc.location.mapID==map then relevant=true end
            end
        end
        local liveMap,x,y=HP.Call(C_QuestLog and C_QuestLog.GetNextWaypoint,quest.questID)
        if liveMap==map or quest.zoneTitle==route.zone then relevant=true end
        if relevant then
            if not q then
                q={name=quest.title,minLevel=1,level=HP.character.level or 1,goals={},navigationPending=true,liveLogOnly=true}
                HP.questData[quest.questID]=q
            end
            if not index[quest.questID] then
                route.steps[#route.steps+1]={action='quest',questID=quest.questID,classes=q.classes,races=q.races,classQuest=q.classQuest,newForever=q.newForever,liveLogOnly=true}
                index[quest.questID]=#route.steps
            end
            if not (HP.normalDeferred and HP.normalDeferred[quest.questID]) then state.skipped[index[quest.questID]]=nil end
        end
    end
    if HP.normalQuestFocus and not HP.Active(HP.normalQuestFocus) then HP.normalQuestFocus=nil end
end
function HP.CycleNormalQuest(delta)
    if HP.db.guideStyle~='normal' or HP.review or not HP.route or not HP.route.catalog or HP.demo then return false end
    local available={};for _,candidate in ipairs(HP.PlanCandidates(HP.route,HP.state.skipped)) do
        local questID=HP.route.steps[candidate.index].questID
        if HP.Active(questID) then available[questID]=candidate.index end
    end
    local order={};local seen={}
    for _,quest in ipairs(HP.normalLogQuests or HP.Quests()) do if available[quest.questID] and not seen[quest.questID] then order[#order+1]=quest.questID;seen[quest.questID]=true end end
    if #order==0 then return false end
    local selected=HP.route.steps[HP.state.index];local position=0
    for i,questID in ipairs(order) do if selected and selected.questID==questID then position=i;break end end
    local nextPosition=((position-1+delta)%#order)+1
    HP.normalQuestFocus=order[nextPosition];HP.state.index=available[HP.normalQuestFocus];HP.normalQuestFocusPhase=HP.QuestStepPhase(HP.route.steps[HP.state.index]).action;HP.manualWaypoint=nil;HP.Refresh();return true
end

function HP.RescanCurrentGuide()
    if HP.Call(InCombatLockdown)==true then HP.rescanPending=true;return end
    HP.rescanPending=nil;HP.normalDeferred={};HP.normalQuestFocus=nil;HP.manualWaypoint=nil;HP.review=false
    HP.resyncGuide=true;HP.abandonDismissed={};HP.UseGuide()
end

