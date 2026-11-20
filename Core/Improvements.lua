local _,HP=...
local function npcID(unit)
    local guid=HP.Call(UnitGUID,unit)
    return type(guid)=='string' and tonumber(guid:match('^[^-]+%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)')),guid
end
local function position()
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player');local p=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,'player')
    local x,y;if p then x,y=HP.Call(p.GetXY,p) end
    if type(x)=='number' and type(y)=='number' then return {mapID=map,x=x,y=y} end
end
local record=HP.RecordQuestLocation
function HP.RecordQuestLocation(event)
    record(event)
    local id=npcID('npc');local loc=position()
    if id and loc then HP.db.npcLocations=HP.db.npcLocations or {};HP.db.npcLocations[id]=loc end
end
local location=HP.StepLocation
function HP.StepLocation(step)
    local phase=HP.QuestStepPhase(step);local q=HP.questData[phase.questID]
    if q and (phase.action=='accept' or phase.action=='turnin') then
        local id=phase.action=='accept' and q.start or q.finish
        local observed=HP.db and HP.db.npcLocations and HP.db.npcLocations[id]
        if observed then return observed end
    end
    if q and phase.action=='objective' and HP.Active(phase.questID) then
        local map,x,y=HP.Call(C_QuestLog and C_QuestLog.GetNextWaypoint,phase.questID)
        if type(map)=='number' and type(x)=='number' and type(y)=='number' and x>=0 and x<=1 and y>=0 and y<=1 then return {mapID=map,x=x,y=y} end
        if not phase.mapID then local synthetic={action='quest',questID=phase.questID};return location(synthetic) end
    end
    return location(step)
end
local build=HP.BuildGuideRows
function HP.BuildGuideRows()
    local rows=build()
    for _,row in ipairs(rows) do row.text=row.text:gsub('^|cffffffff%d+%.|r ',''):gsub('^%d+%. Go to ','Go to ') end
    return rows
end
function HP.Duration(seconds)
    seconds=math.max(0,math.floor(seconds or 0));return string.format('%dm %02ds',math.floor(seconds/60),seconds%60)
end
function HP.PartyMessage(message)
 if HP.Suite and not HP.Suite:On('community') then return end
    if not HP.Call(IsInGroup) or HP.Call(IsInRaid) then return end
    local category=LE_PARTY_CATEGORY_INSTANCE
    local channel=category and HP.Call(IsInGroup,category) and 'INSTANCE_CHAT' or 'PARTY'
    HP.Call(SendChatMessage,'WTF! DUDE SUITE: '..message,channel)
end
function HP.RecordXP(newLevel)
    -- PLAYER_LEVEL_UP can arrive before UnitLevel and the cached character update.
    -- Multiple listeners must never roll the level back and announce it again.
    local function valid(v)return HP.Public(v) and type(v)=='number' and v>=1 and v<=1000 and v or 0 end
    local level=math.max(valid(newLevel),valid(HP.Call(UnitLevel,'player')),valid(HP.character.level),HP.xpState and HP.xpState.level or 1);local xp=HP.Call(UnitXP,'player') or 0;local cap=HP.Call(UnitXPMax,'player') or 1
    local now=HP.Call(GetTime) or 0;local t=HP.xpState
    if not t then HP.xpState={level=level,xp=xp,cap=cap,gain=0,start=now};return end
    if level>t.level then
        if HP.Announce then HP.Announce('level',{level=level,time=HP.Duration(HP.db.levelElapsed)}) elseif HP.db.announceLevelTime then HP.PartyMessage('Reached level '..level..' in '..HP.Duration(HP.db.levelElapsed)..' of tracked play time.') end
        HP.db.levelElapsed=0;HP.db.timedLevel=level;HP.xpState={level=level,xp=xp,cap=cap,gain=0,start=now};return
    end
    if xp>=t.xp then t.gain=t.gain+xp-t.xp end;t.xp=xp;t.cap=cap
end
function HP.UpdateXPFooter()
    local f=HP.frame;if not f then return end
    local t=HP.xpState
    local value=''
    if HP.db.showLevelETA and t then
        local duration=(HP.Call(GetTime) or 0)-t.start
        if duration>=10 and t.gain>0 then value='Next level ~ '..HP.Duration((t.cap-t.xp)*duration/t.gain) else value='Next level: collecting XP rate…' end
    end
    f.note:SetText(value)
    if UnitXP and UnitXPMax and t then f.progress:SetValue(math.max(0,math.min(1,t.xp/math.max(1,t.cap)))) end
end
function HP.CheckQuestAnnouncements(seed)
    HP.questStatuses=HP.questStatuses or {}
    HP.questAnnounced=HP.questAnnounced or {}
    local seen={}
    for _,quest in ipairs(HP.Quests()) do
        local id=quest.questID;seen[id]=true
        local ready=HP.Done({action='objective',questID=id})
        local old=HP.questStatuses[id]
        if not seed and old==false and ready and not HP.questAnnounced[id] then HP.questAnnounced[id]=true;if HP.Announce then HP.Announce('quest',{quest=HP.QuestName(id),questID=id}) elseif HP.db.announceQuestDone then HP.PartyMessage('Quest objectives complete: '..HP.QuestName(id)) end end
        HP.questStatuses[id]=ready
    end
    for id in pairs(HP.questStatuses) do if not seen[id] then HP.questStatuses[id]=nil end end
end
local create=HP.CreateUI
function HP.CreateUI()
    if not HP.db.defaults08 then
        if not HP.db.scale or HP.db.scale==1 then HP.db.scale=.9 end
        if not HP.db.arrowScale or HP.db.arrowScale==1 then HP.db.arrowScale=.8 end
        if HP.db.transparent==nil then HP.db.transparent=true end
        HP.db.defaults08=true
    end
    if HP.db.autoFitStep==nil then HP.db.autoFitStep=true end
    if HP.db.showLevelETA==nil then HP.db.showLevelETA=true end
    HP.db.autoMarkMobs=nil;HP.db.ownedMarks=nil
    if HP.db.announceQuestDone==nil then HP.db.announceQuestDone=true end
    if HP.db.announceLevelTime==nil then HP.db.announceLevelTime=true end
    create();local f=HP.frame
    f.previous:ClearAllPoints();f.previous:SetPoint('TOPLEFT',12,-43)
    f.next:ClearAllPoints();f.next:SetPoint('TOPRIGHT',-45,-43)
    f.tab:ClearAllPoints();f.tab:SetPoint('TOPLEFT',f,'TOPLEFT',40,-47);f.tab:SetPoint('TOPRIGHT',f,'TOPRIGHT',-76,-47);f.tab:SetJustifyH('CENTER')
    f.portrait:Hide()
    f.note:ClearAllPoints();f.note:SetPoint('BOTTOMLEFT',11,16);f.note:SetPoint('BOTTOMRIGHT',-25,16);f.note:SetHeight(13);f.note:SetFont('Fonts\\FRIZQT__.TTF',10)
    f.scroll:SetPoint('BOTTOMRIGHT',-1,34)
    HP.RecordXP();HP.CheckQuestAnnouncements(true)
    if HP.db.timedLevel~=HP.character.level then HP.db.timedLevel=HP.character.level;HP.db.levelElapsed=0 end
    local e=CreateFrame('Frame',nil,UIParent);f.behaviorEvents=e
    for _,event in ipairs({'PLAYER_XP_UPDATE','PLAYER_LEVEL_UP','QUEST_LOG_UPDATE','QUEST_ACCEPTED','QUEST_REMOVED','QUEST_TURNED_IN','PLAYER_TARGET_CHANGED','PLAYER_REGEN_ENABLED'}) do pcall(e.RegisterEvent,e,event) end
    e:SetScript('OnEvent',function(_,event,arg)
        if event=='PLAYER_LEVEL_UP' then HP.RecordXP(arg)
        elseif event=='PLAYER_XP_UPDATE' then HP.RecordXP()
        elseif event:find('QUEST') then HP.CheckQuestAnnouncements(false) end
        HP.UpdateXPFooter()
    end)
    local elapsed=0;e:SetScript('OnUpdate',function(_,dt) elapsed=elapsed+dt;if elapsed>=1 then HP.db.levelElapsed=(HP.db.levelElapsed or 0)+elapsed;elapsed=0;HP.UpdateXPFooter() end end)
end
function HP.AnchorGuideTop()
    local f=HP.frame;if not f or HP.Call(InCombatLockdown)==true then return end
    local point,relative,anchor,x,y=f:GetPoint();if type(point)~='string' then return end
    local amount=point:find('TOP') and 0 or point:find('BOTTOM') and f:GetHeight() or f:GetHeight()/2
    local top=point:find('LEFT') and 'TOPLEFT' or point:find('RIGHT') and 'TOPRIGHT' or 'TOP'
    f:ClearAllPoints();f:SetPoint(top,relative or UIParent,anchor or 'CENTER',x or 0,(y or 0)+amount)
    HP.db.position={top,anchor or 'CENTER',x or 0,(y or 0)+amount}
end
local render=HP.RenderRows
function HP.RenderRows(...)
    render(...);local f=HP.frame
    if HP.db.autoFitStep and not HP.fitting and HP.Call(InCombatLockdown)~=true then
        local height=math.min(950,math.max(155,(HP.guideHeaderHeight or 78)+(f.currentBottom and f.currentBottom>0 and f.currentBottom or f.content:GetHeight() or 0)+(HP.guideFooterHeight or 34)))
        if math.abs(height-f:GetHeight())>1 then HP.fitting=true;HP.AnchorGuideTop();f:SetHeight(height);HP.fitting=false end
    end
    HP.UpdateXPFooter()
end


