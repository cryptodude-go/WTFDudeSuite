local _, HP = ...
function HP.Public(value) return not (issecretvalue and issecretvalue(value)) end
function HP.Call(fn,...)
    if type(fn)~="function" then return nil end
    local ok,a,b,c=pcall(fn,...)
    if not ok or not HP.Public(a) or not HP.Public(b) or not HP.Public(c) then return nil end
    return a,b,c
end
local function contains(list,value)
    if not list then return true end
    for _,v in ipairs(list) do if v==value then return true end end
    return false
end
function HP.DetectCharacter()
    local raceName,race,raceID=HP.Call(UnitRace,"player")
    local className,class=HP.Call(UnitClass,"player")
    local level=math.max(HP.Call(UnitLevel,"player") or 1,HP.levelFromEvent or 0)
    local version,build=HP.Call(GetBuildInfo)
    HP.character={race=race,raceID=raceID,raceName=raceName,class=class,className=className,level=level,version=version,build=build}
    return HP.character
end
function HP.Applies(step)
    local p=HP.character or {}
    return contains(step.races,p.race) and contains(step.classes,p.class)
        and (not step.excludedClasses or not contains(step.excludedClasses,p.class))
end
function HP.Completed(id)
    if id and HP.db and HP.db.guideStyle=="normal" and HP.Active(id) then return false end
    return id and ((HP.db and HP.db.completed and HP.db.completed[id]) or
        HP.Call(C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted or IsQuestFlaggedCompleted,id)==true) or false
end
function HP.Objectives(id)
    local value=HP.Call(C_QuestLog and C_QuestLog.GetQuestObjectives,id)
    return type(value)=="table" and value or {}
end
function HP.Active(id)
    local index=HP.Call(C_QuestLog and C_QuestLog.GetLogIndexForQuestID,id)
    return type(index)=="number" and index>0
end
function HP.Done(step)
    if not HP.Applies(step) then return true end
    if step.action=="level" then return ((HP.character and HP.character.level) or HP.Call(UnitLevel,"player") or 1)>=step.targetLevel end
    if step.action=="buy" then return HP.ItemCount(step.itemID)>=(step.count or 1) end
    if HP.Completed(step.questID) then return true end
    if step.action=="accept" then return HP.Active(step.questID) end
    if step.action=="turnin" or not HP.Active(step.questID) then return false end
    local objectives=HP.Objectives(step.questID)
    if step.objectiveIndex then
        local o=objectives[step.objectiveIndex]
        return o and HP.Public(o.finished) and o.finished==true or false
    end
    if #objectives==0 then
        return HP.Call(C_QuestLog and C_QuestLog.IsComplete,step.questID)==true
    end
    for _,o in ipairs(objectives) do
        if not HP.Public(o.finished) or o.finished~=true then return false end
    end
    return true
end
function HP.NextStep(route,index,skipped)
    while index<=#route.steps and (skipped[index] or HP.Done(route.steps[index])) do index=index+1 end
    return index,route.steps[index]
end
function HP.Route(race,build)
    local ids={}
    for id in pairs(HP.routes) do ids[#ids+1]=id end
    table.sort(ids)
    for _,id in ipairs(ids) do
        local r=HP.routes[id]
        -- Keep old strict build records usable, but don't label candidate data verified.
        if (not r.verifiedBuild or tostring(r.verifiedBuild)==tostring(build)) and contains(r.races,race) then
            return id,r
        end
    end
end
function HP.Quests()
    local result={};local header
    local count=HP.Call(C_QuestLog and C_QuestLog.GetNumQuestLogEntries) or 0
    for i=1,count do
        local q=HP.Call(C_QuestLog and C_QuestLog.GetInfo,i)
        if q and HP.Public(q.isHeader) and q.isHeader and HP.Public(q.title) then header=q.title end
        if q and HP.Public(q.isHeader) and not q.isHeader and HP.Public(q.isHidden) and not q.isHidden
            and HP.Public(q.questID) and type(q.questID)=="number" then
            result[#result+1]={questID=q.questID,title=HP.Public(q.title) and q.title or "Quest",zoneTitle=header}
        end
    end
    return result
end
function HP.ObjectiveText(text)
    text=type(text)=="string" and text or "Quest objective"
    -- The client may supply either a leading or trailing tracker count.
    text=text:gsub("^%s*%d+%s*/%s*%d+%s*", "")
    text=text:gsub("%s*%(?%d+%s*/%s*%d+%)?%s*$", "")
    return (text:gsub("[:%s]+$", ""))
end
function HP.Progress(o,description)
    local value=description or (HP.Public(o.text) and o.text or "Quest objective")
    local have,need=o.numFulfilled,o.numRequired
    if HP.Public(have) and HP.Public(need) and type(have)=="number" and type(need)=="number" and need>0 then
        return HP.ObjectiveText(value).." |cffa2e985("..string.format("%d/%d",have,need)..")|r"
    end
    return value
end
function HP.QuestName(id)
    return HP.Call(C_QuestLog and C_QuestLog.GetTitleForQuestID,id) or
        (HP.questData[id] and HP.questData[id].name) or ("Quest "..id)
end
function HP.Entity(kind,id)
    if kind=="kill" then return HP.npcData[id] end
    if kind=="object" then return HP.objectData[id] end
    if kind=="item" then return HP.itemData[id] end
end
function HP.GoalLocation(goal)
    local entity=HP.Entity(goal.kind,goal.id)
    if not entity then return nil end
    if entity.location and entity.location.mapID then return entity.location end
    if goal.kind=="item" then
        for _,id in ipairs(entity.objects or {}) do
            local object=HP.objectData[id]
            if object and object.location and object.location.mapID then return object.location end
        end
        for _,id in ipairs(entity.mobs or {}) do
            local mob=HP.npcData[id]
            if mob and mob.location and mob.location.mapID then return mob.location end
        end
    end
end
function HP.StepLocation(step)
    if step.action=="buy" then local vendor=HP.Vendor(step); return vendor and vendor.location end
    if step.mapID and step.x and step.y then return {mapID=step.mapID,x=step.x,y=step.y} end
    local q=HP.questData[step.questID]
    if not q then return nil end
    if step.action=="accept" or step.action=="turnin" then
        local npc=HP.npcData[step.action=="accept" and q.start or q.finish]
        return npc and npc.location
    end
    local objectives=HP.Objectives(step.questID)
    for i,goal in ipairs(q.goals or {}) do
        local o=objectives[i]
        if not o or not HP.Public(o.finished) or not o.finished then
            local location=HP.GoalLocation(goal)
            if location then return location end
        end
    end
end
function HP.Creature(unit)
    if InCombatLockdown and InCombatLockdown() then return nil end
    local guid=HP.Call(UnitGUID,unit)
    if type(guid)~="string" then return nil end
    local kind,_,_,_,_,id=strsplit("-",guid)
    if kind=="Creature" or kind=="Vehicle" then return tonumber(id) end
end
function HP.PlateLines(unit)
    local id,lines=HP.Creature(unit),{}
    for _,r in ipairs(id and HP.mobObjectives[id] or {}) do
        if HP.Active(r.questID) and not HP.Completed(r.questID) then
            local o=HP.Objectives(r.questID)[r.objectiveIndex]
            if o and HP.Public(o.finished) and not o.finished then
                local icon=r.itemID and HP.Call(C_Item and C_Item.GetItemIconByID,r.itemID)
                lines[#lines+1]=(icon and ("|T"..icon..":14|t ") or "")..HP.Progress(o)
            end
        end
    end
    return lines
end


