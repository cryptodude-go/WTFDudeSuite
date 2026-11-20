local _,HP=...
HP.guideOrder={}
for _,zone in ipairs(HP.zoneCatalog) do
    local r={id=zone.id,title=zone.name.." ("..zone.minLevel.."-"..zone.maxLevel..")",minLevel=zone.minLevel,maxLevel=zone.maxLevel,mapID=zone.mapID,zone=zone.name,revision=2,catalog=true,steps={},source=zone.quality,description=zone.description,newQuestIDs=zone.newQuestIDs}
    for _,id in ipairs(zone.questIDs) do
        local q=HP.questData[id]
        r.steps[#r.steps+1]={action="quest",questID=id,classes=q.classes,races=q.races,classQuest=q.classQuest,section=zone.name.." · Levels "..zone.minLevel.."-"..zone.maxLevel,hint="Follow the objective locations, then return for the reward."}
    end
    for _,id in ipairs(zone.newQuestIDs) do
        local q=HP.foreverQuests[id];HP.questData[id]=q
        r.steps[#r.steps+1]={action="quest",questID=id,classes=q.classes,races=q.races,newForever=true,section=zone.name.." · Forever quests",hint=q.hint or "Follow the live quest objectives. Exact locations are not yet indexed."}
    end
    HP.routes[r.id]=r;HP.guideOrder[#HP.guideOrder+1]=r.id
end
local oldApplies=HP.Applies
function HP.Applies(step)
    local accepted=HP.db and HP.db.guideStyle=="normal" and (HP.Active(step.questID) or HP.LiveQuestOffer and HP.LiveQuestOffer(step.questID))
    if not accepted and not oldApplies(step) then return false end
    local kind=HP.QuestDifficulty and HP.QuestDifficulty(step.questID)
    if kind=='raid' and HP.db.includeRaidQuests~=true then return false end
    if kind=='group' and HP.db.includeGroupQuests~=true then return false end
    local q=step.questID and HP.questData[step.questID]
    if not accepted and q and q.raceMask and q.raceMask>0 then
        local bit=HP.RaceQuestBit and HP.RaceQuestBit(HP.character.raceID,HP.character.race)
        if not bit or math.floor(q.raceMask/bit)%2==0 then return false end
    end
    if HP.db and HP.db.includeClassQuests==false and (step.classes or step.classQuest or q and q.classQuest) then return false end
    if HP.db and HP.db.includeForeverQuests==false and (step.newForever or q and q.newForever) then return false end
    return true
end
local oldDone=HP.Done
function HP.Done(step)
    if step.action=="quest" then return not HP.Applies(step) or HP.Completed(step.questID) end
    return oldDone(step)
end
function HP.QuestStepPhase(step)
    if step.action~="quest" then return step end
    local result={};for k,v in pairs(step) do result[k]=v end
    if not HP.Active(step.questID) then result.action="accept"
    elseif oldDone({action="objective",questID=step.questID}) then result.action="turnin"
    else result.action="objective" end
    return result
end
local oldLocation=HP.StepLocation
function HP.StepLocation(step)
    local s=HP.QuestStepPhase(step);local q=HP.questData[s.questID]
    if q then
        local live=HP.db and HP.db.questLocations and HP.db.questLocations[s.questID]
        if s.action=="accept" or s.action=="turnin" then
            local object=HP.objectData[s.action=="accept" and q.startObject or q.finishObject]
            if object and object.location then return object.location end
            if live and live[s.action] then return live[s.action] end
        end
    end
    local loc=oldLocation(s)
    if loc then return loc end
    if q and HP.Active(s.questID) then
        local map,x,y=HP.Call(C_QuestLog and C_QuestLog.GetNextWaypoint,s.questID)
        if type(map)=="number" and type(x)=="number" and type(y)=="number" then return {mapID=map,x=x,y=y} end
    end
    if q and not q.newForever and s.action=="objective" and #(q.goals or {})==0 then
        local npc=HP.npcData[q.finish];return npc and npc.location
    end
end
local oldRows=HP.StepRows
function HP.StepRows(step,compact)
    local s=HP.QuestStepPhase(step)
    local rows=oldRows(s,compact)
    if step.action=="quest" and s.action=="accept" then
        local q=HP.questData[step.questID]
        if q and q.startObject then
            local object=HP.objectData[q.startObject]
            if object and not compact then table.insert(rows,1,{kind="talk",text="Read "..object.name}) end
        elseif q and q.startItem and not compact then
            local item=HP.itemData[q.startItem];table.insert(rows,1,{kind="use",text="Use "..(item and item.name or "the quest-starting item"),itemID=q.startItem,icon=HP.Call(C_Item and C_Item.GetItemIconByID,q.startItem)})
        end
    end
    return rows
end
local oldName=HP.DestinationName
function HP.DestinationName(step) return oldName(HP.QuestStepPhase(step)) end
function HP.PrerequisitesMet(q)
    for _,id in ipairs(q.prerequisiteAll or {}) do if not HP.Completed(math.abs(id)) then return false end end
    if #(q.prerequisites or {})>0 then
        local any=false;for _,id in ipairs(q.prerequisites) do if HP.Completed(math.abs(id)) then any=true end end
        if not any then return false end
    end
    for _,id in ipairs(q.exclusive or {}) do if HP.Completed(id) or HP.Active(id) then return false end end
    return true
end
function HP.QuestDifficulty(id)
    local q=HP.questData[id] or {};local kind=q.questType
    if q.raidQuest or kind==62 or kind==88 or kind==89 then return 'raid' end
    if q.groupRecommended or kind==1 or kind==81 or q.groupSize and q.groupSize>1 then return 'group' end
end
function HP.CandidateScore(step)
    if not HP.Applies(step) or HP.Completed(step.questID) then return end
    local q=HP.questData[step.questID];if not q then return end
    local active=HP.Active(step.questID)
    if not active then
        if q.parentQuest and not HP.Active(q.parentQuest) then return end
        if q.nextQuest and (HP.Active(q.nextQuest) or HP.Completed(q.nextQuest)) then return end
        if q.maxLevel and q.maxLevel>0 and HP.character.level>q.maxLevel then return end
        if q.requiredSpell and not HP.Call(IsSpellKnown,q.requiredSpell) then return end
        if q.groupRecommended and HP.db.includeGroupQuests~=true then return end
        for _,item in ipairs(q.requiredSourceItems or {}) do if (HP.Call(C_Item and C_Item.GetItemCount,item) or 0)==0 then return end end
    end
    if not active and HP.db.guideStyle~="normal" and (q.level or 1)>(HP.character.level or 1)+3 then return end
    if not active and q.startItem and (HP.Call(C_Item and C_Item.GetItemCount,q.startItem) or 0)==0 then return end
    if not active and ((HP.character.level or 1)<(q.minLevel or 1) or not HP.PrerequisitesMet(q) or q.navigationPending) then return end
    local loc=HP.StepLocation(step)
    if not active and not loc then return end
    local dx,dy
    if loc then dx,dy=HP.NavigationVector(loc) end
    local distance=dx and math.sqrt(dx*dx+dy*dy) or 1500
    local score=distance/80+math.abs((q.level or q.minLevel or 1)-(HP.character.level or 1))*2
    if active then score=score-25 end
    if not active and distance<30 then score=score-55 end -- batch nearby pickups
    if active and HP.QuestStepPhase(step).action=="turnin" then score=score-15 end
    return score
end
function HP.PlanCandidates(route,skipped)
    local result={}
    for i,step in ipairs(route.steps) do
        if not skipped or not skipped[i] then local score=HP.CandidateScore(step);if score then result[#result+1]={index=i,score=score} end end
    end
    table.sort(result,function(a,b) if a.score==b.score then return a.index<b.index end return a.score<b.score end)
    return result
end
local oldNext=HP.NextStep
function HP.NextStep(route,index,skipped)
    if not route.catalog then return oldNext(route,index,skipped) end
    local candidates=HP.PlanCandidates(route,skipped)
    route.blocked=#candidates==0
    return candidates[1] and candidates[1].index or #route.steps+1
end
local oldRoute=HP.Route
local starts={Orc="durotar",Troll="durotar",Tauren="mulgore",Scourge="tirisfal"}
function HP.Route(race,build)
    local chosen=HP.db and HP.db.selectedGuide
    if chosen and HP.routes[chosen] then return chosen,HP.routes[chosen] end
    local level=HP.character and HP.character.level or 1
    if level<=10 and starts[race] then local id=starts[race];return id,HP.routes[id] end
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,"player")
    for _,id in ipairs(HP.guideOrder) do local r=HP.routes[id];if r.mapID==map and level>=r.minLevel and level<=r.maxLevel then return id,r end end
    local id=level<=30 and "zone_17" or level<=40 and "zone_33" or level<=50 and "zone_440" or level<=55 and "zone_490" or "zone_139"
    return id,HP.routes[id]
end
function HP.SelectGuide(id)
    if not HP.routes[id] then return end
    HP.db.selectedGuide=id;HP.UseGuide()
end
function HP.GuideStats(route)
    local total,class,new,pending,seen=0,0,0,0,{}
    for _,step in ipairs(route.steps) do
        local id=step.questID
        if id and not seen[id] then
            seen[id]=true;total=total+1;local q=HP.questData[id] or {}
            if step.classes or q.classQuest then class=class+1 end
            if q.newForever then new=new+1 end
            if q.navigationPending or q.prerequisitesUnverified then pending=pending+1 end
        end
    end
    return total,class,new,pending
end
function HP.RecordQuestLocation(event)
    local id=HP.Call(GetQuestID);if type(id)~="number" or id<=0 then return end
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,"player")
    local pos=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,"player")
    local x,y;if pos then x,y=HP.Call(pos.GetXY,pos) end
    if type(x)~="number" or type(y)~="number" then return end
    HP.db.questLocations=HP.db.questLocations or {};HP.db.questLocations[id]=HP.db.questLocations[id] or {}
    HP.db.questLocations[id][event=="QUEST_DETAIL" and "accept" or "turnin"]={mapID=map,x=x,y=y}
end
-- Rebuild nameplate associations from the full factual index.
local registered={}
for id,q in pairs(HP.questData) do
    for index,goal in ipairs(q.goals or {}) do
        local mobs=goal.kind=="kill" and {goal.id} or goal.kind=="item" and HP.itemData[goal.id] and HP.itemData[goal.id].mobs or {}
        for _,mob in ipairs(mobs) do
            local key=id..":"..index..":"..mob
            if not registered[key] then
                registered[key]=true;HP.mobObjectives[mob]=HP.mobObjectives[mob] or {}
                local exists=false;for _,entry in ipairs(HP.mobObjectives[mob]) do if entry.questID==id and entry.objectiveIndex==index then exists=true end end
                if not exists then HP.mobObjectives[mob][#HP.mobObjectives[mob]+1]={questID=id,objectiveIndex=index,itemID=goal.kind=="item" and goal.id or nil,kind=goal.kind,targetID=goal.id} end
            end
        end
    end
end

