local _,HP=...
-- Ding v1.8.1 / QuestieDB v1.0.6 facts, GPL-3.0. See Licenses/Ding-DB-CREDITS.md.
local db=HP.DingSource.DB
HP.enrichmentStats={quests=0,added=0,goals=0,pickups=0,contactsUpdated=0,npcs=0,objects=0,items=0}
local function firstPosition(spawns)
 local map;for id in pairs(spawns or {}) do if not map or id<map then map=id end end
 local coords=map and spawns[map];if coords and coords[1] and coords[2] then return {mapID=map,x=coords[1]/100,y=coords[2]/100} end
end
for id,v in pairs(db.npcs) do
 local n=HP.npcData[id] or {name=v[1]};HP.npcData[id]=n
 n.dingCoords=v[5];n.location=n.location or firstPosition(v[5])
 n.minLevel=n.minLevel or v[2];n.maxLevel=n.maxLevel or v[3];HP.enrichmentStats.npcs=HP.enrichmentStats.npcs+1
end
for id,v in pairs(db.objects) do
 local n=HP.objectData[id] or {name=v[1]};HP.objectData[id]=n
 n.dingCoords=v[2];n.location=n.location or firstPosition(v[2]);HP.enrichmentStats.objects=HP.enrichmentStats.objects+1
end
for id,v in pairs(db.items) do
 local n=HP.itemData[id] or {name=v[1]};HP.itemData[id]=n
 n.mobs=n.mobs or v[2];n.objects=n.objects or v[3];n.vendors=n.vendors or v[4];HP.enrichmentStats.items=HP.enrichmentStats.items+1
end
local function first(v,kind) return v and v[kind] and v[kind][1] end
local function bits(mask)
 local result={};local names={'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','DEATHKNIGHT','SHAMAN','MAGE','WARLOCK','MONK','DRUID'}
 for i,name in ipairs(names) do if math.floor((mask or 0)/2^(i-1))%2==1 then result[#result+1]=name end end
 return #result>0 and result or nil
end
for id,v in pairs(db.quests) do
 local q=HP.questData[id]
 if not q then q={name=v[1],goals={}};HP.questData[id]=q;HP.enrichmentStats.added=HP.enrichmentStats.added+1 end
 if not q.skyborneReviewed then
  q.name=q.name or v[1];q.minLevel=v[4] or q.minLevel;q.level=v[5] or q.level
  if not q.reviewed then
   if v[2] then
    local npc,object,item=first(v[2],1),first(v[2],2),first(v[2],3)
    if q.start~=npc or q.startObject~=object or q.startItem~=item then HP.enrichmentStats.contactsUpdated=HP.enrichmentStats.contactsUpdated+1 end
    q.start,q.startObject,q.startItem=npc,object,item
   end
   if v[3] then q.finish,q.finishObject=first(v[3],1),first(v[3],2) end
  else
   q.start=q.start or first(v[2],1);q.finish=q.finish or first(v[3],1)
   q.startObject=q.startObject or first(v[2],2);q.finishObject=q.finishObject or first(v[3],2);q.startItem=q.startItem or first(v[2],3)
  end
  q.classes=q.classes or bits(v[7]);q.classQuest=q.classQuest or (v[7] and v[7]>0) or nil
  q.raceMask=v[6] or q.raceMask;q.useItemID=q.useItemID or v[10]
  if not q.prerequisiteAll and v[11] then q.prerequisiteAll=v[11] end
  if not q.prerequisites and v[12] then q.prerequisites=v[12] end
  if not q.goals or #q.goals==0 then
   q.goals={};for kind,rows in pairs(v[9] or {}) do local name=({[1]='kill',[2]='object',[3]='item'})[kind]
    if name then for _,goal in ipairs(rows) do q.goals[#q.goals+1]={kind=name,id=goal[1],count=1} end end
   end
   if #q.goals>0 then HP.enrichmentStats.goals=HP.enrichmentStats.goals+1 end
  end
  local giver=q.start and HP.npcData[q.start] or q.startObject and HP.objectData[q.startObject]
  local point=giver and (firstPosition(giver.dingCoords) or giver.location)
  if point then
   if q.navigationPending then HP.enrichmentStats.pickups=HP.enrichmentStats.pickups+1 end
   q.startLocation=q.startLocation or point;q.navigationPending=nil
   -- Missing prerequisite metadata stays conservative; explicit exported chains are usable.
   if v[11] or v[12] then q.prerequisitesUnverified=nil end
  end
 end
 q.dingReference=true;HP.enrichmentStats.quests=HP.enrichmentStats.quests+1
end
function HP.LibraryEntityLocation(kind,id)
 local e=kind=='npc' and HP.npcData[id] or kind=='object' and HP.objectData[id] or HP.itemData[id]
 local best,score
 local current=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
 local now=HP.Call(GetTime) or 0;local saved=e and e.dingChoice
 local pos=current and HP.Call(C_Map and C_Map.GetPlayerMapPosition,current,'player');local px,py;if pos then px,py=HP.Call(pos.GetXY,pos) end
 local cell=type(px)=='number' and type(py)=='number' and (math.floor(px*500)..':'..math.floor(py*500)) or ''
 if saved and saved.map==current and saved.cell==cell and saved.untilAt>now then return saved.point end
 local width,height=HP.Call(C_Map and C_Map.GetMapWorldSize,current)
 local planar=type(px)=='number' and type(py)=='number' and type(width)=='number' and width>0 and type(height)=='number' and height>0
 for map,coords in pairs(e and e.dingCoords or {}) do
  if map==current or not (e.dingCoords and e.dingCoords[current]) then
   for i=1,#coords,2 do local p={mapID=map,x=coords[i]/100,y=coords[i+1]/100}
    local dx,dy
    if map==current and planar then dx,dy=(p.x-px)*width,(py-p.y)*height else dx,dy=HP.NavigationVector(p) end
    local d=dx and dx*dx+dy*dy or 1e14
    if not score or d<score then best,score=p,d end
   end
  end
 end
 if e then e.dingChoice={map=current,cell=cell,untilAt=now+.5,point=best or e.location} end
 return best or e and e.location
end
local questIds={};for id in pairs(db.quests) do questIds[#questIds+1]=id end;table.sort(questIds)
local zoneByMap={};for _,z in ipairs(HP.zoneCatalog) do zoneByMap[z.mapID]=z end
HP.enrichmentStats.zoneEntries=0
for _,id in ipairs(questIds) do
 local q=HP.questData[id];local point=q.startLocation;local z=point and zoneByMap[point.mapID]
 if z and not q.skyborneReviewed then
  local route=HP.routes[z.id];local present=false
  for _,step in ipairs(route and route.steps or {}) do if step.questID==id then present=true;break end end
  if route and not present then
   q.newForever=q.newForever or id>=90000
   local list=q.newForever and z.newQuestIDs or z.questIDs;list[#list+1]=id
   if q.newForever then HP.foreverQuests[id]=q end
   route.steps[#route.steps+1]={action='quest',questID=id,classes=q.classes,races=q.races,classQuest=q.classQuest,newForever=q.newForever,section=z.name,hint='Follow the live objectives.'}
   HP.enrichmentStats.zoneEntries=HP.enrichmentStats.zoneEntries+1
  end
 end
end
local location=HP.StepLocation
function HP.StepLocation(step)
 local phase=HP.QuestStepPhase(step);local q=HP.questData[phase.questID]
 if not q or q.skyborneReviewed or step.mapID then return location(step) end
 local observed=HP.db and HP.db.questLocations and HP.db.questLocations[phase.questID]
 if observed and observed[phase.action] then return observed[phase.action] end
 if phase.action=='accept' or phase.action=='turnin' then
  local id=phase.action=='accept' and q.start or q.finish
  local object=phase.action=='accept' and q.startObject or q.finishObject
  local seen=id and HP.db and HP.db.npcLocations and HP.db.npcLocations[id]
  if seen then return seen end
  local found=id and HP.LibraryEntityLocation('npc',id) or object and HP.LibraryEntityLocation('object',object)
  if found then return found end
 elseif phase.action=='objective' then
  if HP.Active(phase.questID) then
   local map,x,y=HP.Call(C_QuestLog and C_QuestLog.GetNextWaypoint,phase.questID)
   if type(map)=='number' and type(x)=='number' and type(y)=='number' and x>=0 and x<=1 and y>=0 and y<=1 then return {mapID=map,x=x,y=y} end
  end
  local objectives=HP.Objectives(phase.questID)
  for i,goal in ipairs(q.goals or {}) do
   if not objectives[i] or not objectives[i].finished then
    if goal.kind=='kill' or goal.kind=='object' then local found=HP.LibraryEntityLocation(goal.kind=='kill' and 'npc' or 'object',goal.id);if found then return found end
    elseif goal.kind=='item' then
     local item=HP.itemData[goal.id];local best,distance
     for _,entry in ipairs({{'object',item and item.objects},{'npc',item and item.mobs}}) do for _,id in ipairs(entry[2] or {}) do
      local p=HP.LibraryEntityLocation(entry[1],id);local dx,dy;if p then dx,dy=HP.NavigationVector(p) end
      local value=dx and dx*dx+dy*dy or 1e14;if p and (not distance or value<distance) then best,distance=p,value end
     end end
     if best then return best end
    end
    break
   end
  end
 end
 return location(step)
end

-- Fill nameplate links for objectives that were absent when the original planner loaded.
for id,q in pairs(HP.questData) do for index,goal in ipairs(q.goals or {}) do
 local targets=goal.kind=='kill' and {goal.id} or goal.kind=='item' and HP.itemData[goal.id] and HP.itemData[goal.id].mobs or {}
 for _,mob in ipairs(targets) do
  local list=HP.mobObjectives[mob] or {};HP.mobObjectives[mob]=list;local exists
  for _,entry in ipairs(list) do if entry.questID==id and entry.objectiveIndex==index then exists=true;break end end
  if not exists then list[#list+1]={questID=id,objectiveIndex=index,itemID=goal.kind=='item' and goal.id or nil,kind=goal.kind,targetID=goal.id} end
 end
end end
