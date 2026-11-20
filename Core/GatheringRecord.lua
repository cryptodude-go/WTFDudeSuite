local _,HP=...
local function now() return HP.Call(GetTime) or 0 end
local function kindForSpell(id)
 if not HP.Public(id) or type(id)~='number' then return end
 local name=HP.ReadGuideAPI(C_Spell and C_Spell.GetSpellName or GetSpellInfo,id)
 for _,row in ipairs({{2575,'Mining'},{2366,'Herbalism'}}) do
  local base=HP.ReadGuideAPI(C_Spell and C_Spell.GetSpellName or GetSpellInfo,row[1])
  if id==row[1] or name and base and name==base then return row[2] end
 end
end
function HP.RecordGatherNode(id,pos)
 id=HP.gatherNodeAliases[id] or id
 if not HP.db or not HP.gatherNodeInfo[id] or not pos or not pos.mapID or type(pos.x)~='number' or type(pos.y)~='number' or pos.x<=0 or pos.x>=1 or pos.y<=0 or pos.y>=1 then return false end
 HP.MarkGatherVisit(pos,HP.gatherNodeInfo[id].kind,true)
 if HP.db.gatherRecord==false then return true end
 HP.db.gatherNodes=HP.db.gatherNodes or {};local nodes=HP.db.gatherNodes[pos.mapID] or {};HP.db.gatherNodes[pos.mapID]=nodes
 local w,h=HP.Call(C_Map and C_Map.GetMapWorldSize,pos.mapID);w=type(w)=='number' and w>0 and w or 5000;h=type(h)=='number' and h>0 and h or 3333
 local stamp=HP.Call(time) or 0
 for _,p in ipairs(nodes) do if p.id==id and ((p.x-pos.x)*w)^2+((p.y-pos.y)*h)^2<25^2 then
  if stamp-(p.last or 0)>=3 then p.hits=(p.hits or 1)+1;p.last=stamp end
  return true
 end end
 nodes[#nodes+1]={id=id,x=pos.x,y=pos.y,hits=1,last=stamp}
 if #nodes>500 then table.remove(nodes,1) end
 -- Bound the per-character catalogue as well as each individual zone.
 local total=0;local oldestMap,oldestIndex,oldest
 for map,list in pairs(HP.db.gatherNodes) do for i,p in ipairs(list) do total=total+1;if not oldest or (p.last or 0)<oldest then oldestMap,oldestIndex,oldest=map,i,p.last or 0 end end end
 if total>4000 then table.remove(HP.db.gatherNodes[oldestMap],oldestIndex) end
 HP.InvalidateGathering();return true
end
function HP.ReadGatherLoot()
 if HP.Suite and not HP.Suite:On('gathering') then return end
 if not HP.db then return end
 local position=HP.GatherPosition();if not position then return end
 local pending=HP.pendingGather
 if pending and (not pending.success or now()-pending.at>12 or pending.pos.mapID~=position.mapID) then pending=nil end
 local found=false;local slots=HP.Call(GetNumLootItems) or 0
 for slot=1,math.min(32,slots) do
  local sources={HP.ReadGuideAPI(GetLootSourceInfo,slot)}
  for i=1,#sources,2 do local guid=sources[i]
   if HP.Public(guid) and type(guid)=='string' then
    local id=tonumber(guid:match('^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-'))
    id=id and (HP.gatherNodeAliases[id] or id)
    if id and HP.gatherNodeInfo[id] then
     if HP.RecordGatherNode(id,pending and pending.kind==HP.gatherNodeInfo[id].kind and pending.pos or position) then found=true end
    end
   end
  end
 end
 -- Older clients may omit loot-source GUIDs. Require both a successful gather
 -- cast and a matching resource yield; buying/trading ordinary items cannot log nodes.
 if not found and pending then
  for slot=1,math.min(32,slots) do
   local link=HP.Call(GetLootSlotLink,slot);local item=type(link)=='string' and tonumber(link:match('item:(%d+)'))
   if item then local chosen,ambiguous
    local alias=HP.gatherAliasNames[pending.target]
    if alias and HP.gatherNodeInfo[alias].item==item and HP.gatherNodeInfo[alias].kind==pending.kind then found=HP.RecordGatherNode(alias,pending.pos);break end
    for id,info in pairs(HP.gatherNodeInfo) do if info.item==item and info.kind==pending.kind then
     if info.name==pending.target then chosen=id;ambiguous=false;break end
     if chosen and chosen~=id then ambiguous=true else chosen=id end
    end end
    if chosen and not ambiguous then found=HP.RecordGatherNode(chosen,pending.pos) end
   end
   if found then break end
  end
 end
 if found then HP.pendingGather=nil end
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local f=CreateFrame('Frame',nil,UIParent);HP.gatherRecordEvents=f
 for _,event in ipairs({'UNIT_SPELLCAST_SENT','UNIT_SPELLCAST_SUCCEEDED','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_INTERRUPTED','LOOT_OPENED','LOOT_READY','ZONE_CHANGED_NEW_AREA','PLAYER_ENTERING_WORLD'}) do pcall(f.RegisterEvent,f,event) end
 f:SetScript('OnEvent',function(_,event,unit,a,b,c)
  if event=='UNIT_SPELLCAST_SENT' then
   if unit~='player' then return end
   local kind=kindForSpell(c);local pos=HP.GatherPosition()
   HP.pendingGather=kind and pos and HP.Public(a) and type(a)=='string' and {kind=kind,target=a,pos=pos,at=now(),success=false,cast=b} or nil
  elseif event=='UNIT_SPELLCAST_SUCCEEDED' then
   if unit~='player' then return end
   local p=HP.pendingGather;if p and kindForSpell(b)==p.kind and (not p.cast or p.cast==a) then p.success=true;p.at=now() end
  elseif event=='UNIT_SPELLCAST_FAILED' or event=='UNIT_SPELLCAST_INTERRUPTED' then if unit=='player' then HP.pendingGather=nil end
  elseif event=='LOOT_OPENED' or event=='LOOT_READY' then HP.ReadGatherLoot()
  else HP.pendingGather=nil;HP.gatherLastMap=nil end
 end)
end
