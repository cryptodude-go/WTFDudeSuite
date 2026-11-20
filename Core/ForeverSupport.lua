local _,HP=...
-- Positive observations belong to this character/session, never a shared eligibility rule.
HP.liveQuestOffers={}
function HP.RaceQuestBit(id,race)
 if id==95 then return 4294967296 end
 if id==96 then return 8589934592 end
 if not id then
  if race=='Skyborne' then return HP.Call(UnitFactionGroup,'player')=='Alliance' and 4294967296 or 8589934592 end
  id=({Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Tauren=6,Gnome=7,Troll=8})[race]
 end
 if type(id)=='number' and id>=1 and id<=32 then return 2^(id-1) end
end
local resolve=HP.ResolveForeverMaps
function HP.ResolveForeverMaps()
 local info=HP.Call(C_Map and C_Map.GetMapInfo,2521)
 if type(info)=='table' and info.mapID~=0 then HP.zephrasMap=2521 end
 resolve()
 if not HP.zephrasMap then return end
 for _,z in ipairs(HP.zoneCatalog) do if z.areaID==16593 then z.mapID=HP.zephrasMap end end
 local r=HP.routes.zone_16593;if r then r.mapID=HP.zephrasMap end
 for _,entities in ipairs({HP.npcData,HP.objectData}) do for _,entity in pairs(entities) do
  if entity.location and entity.location.zoneID==16593 then entity.location.mapID=HP.zephrasMap end
  for _,point in ipairs(entity.spawns or {}) do if point.zoneID==16593 then point.mapID=HP.zephrasMap end end
 end end
end
function HP.LiveQuestOffer(id)
 local offer=HP.liveQuestOffers[id]
 if not offer then return end
 local now=HP.Call(GetTime) or 0
 if now-offer.at>1800 or offer.mapID~=HP.CurrentGuideMap() then HP.liveQuestOffers[id]=nil;return end
 return offer
end
local function position()
 local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
 local p=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,'player')
 local x,y;if p and type(p.GetXY)=='function' then x,y=HP.Call(p.GetXY,p) end
 if type(map)=='number' and type(x)=='number' and type(y)=='number' and x>=0 and x<=1 and y>=0 and y<=1 then return {mapID=map,x=x,y=y} end
end
function HP.ObserveQuestOffers()
 if not HP.db then return end
 local offers=HP.Call(C_GossipInfo and C_GossipInfo.GetAvailableQuests)
 if type(offers)~='table' then return end
 local loc=position();if not loc then return end
 HP.db.observedQuestFacts=HP.db.observedQuestFacts or {}
 for _,offer in ipairs(offers) do
  local id=offer.questID
  if HP.Public(id) and type(id)=='number' and id>0 then
   local q=HP.questData[id]
   -- Unknown quests are reconciled from the accepted live log, never invented here.
   if q then
    HP.liveQuestOffers[id]={at=HP.Call(GetTime) or 0,mapID=HP.CurrentGuideMap(),location=loc}
    HP.db.questLocations=HP.db.questLocations or {};HP.db.questLocations[id]=HP.db.questLocations[id] or {};HP.db.questLocations[id].accept=loc
    local title=offer.title
    if HP.Public(title) and type(title)=='string' and title~='' then q.name=title;HP.db.observedQuestFacts[id]={name=title} end
   end
  end
 end
end
local score=HP.CandidateScore
function HP.CandidateScore(step)
 if HP.db and HP.db.guideStyle=='normal' and HP.LiveQuestOffer(step.questID) and not HP.Active(step.questID) then
  if not HP.Applies(step) or HP.Completed(step.questID) then return end
  -- The server has offered this exact quest to this character. Do not let stale
  -- beta masks/prerequisites hide it; all user class/group/Forever filters remain.
  return -50000
 end
 return score(step)
end
local setStyle=HP.SetGuideStyle
function HP.SetGuideStyle(style)
 if style=='speed' and HP.CurrentGuideMap()==2521 then
  print('|cffffa640Dude:|r Zephras Isle has no Classic speedrun route. Use Normal for the Skyborne introduction, then select Speedrun after leaving.')
  return
 end
 return setStyle(style)
end
local route=HP.Route
function HP.Route(race,build)
 HP.ResolveForeverMaps()
 if HP.db and HP.db.guideStyle=='speed' and HP.CurrentGuideMap()==2521 then
  HP.db.guideStyle='normal';HP.db.selectedGuide=nil
  print('|cffffa640Dude:|r Using Normal for Zephras Isle. Classic Speedrun is available after the Skyborne introduction.')
 end
 return route(race,build)
end
function HP.ForeverCoverage()
 local c={indexed=0,zephras=0,located=0,pending=0}
 for _,q in pairs(HP.foreverQuests) do
  if not q.snapshotUnavailable then
   c.indexed=c.indexed+1
   if q.zoneID==16593 then c.zephras=c.zephras+1 end
   if q.startLocation or (q.start and HP.npcData[q.start] and HP.npcData[q.start].location) then c.located=c.located+1 end
   if q.prerequisitesUnverified or q.navigationPending then c.pending=c.pending+1 end
  end
 end
 return c
end
local diagnostics=HP.ShowDiagnostics
function HP.ShowDiagnostics()
 diagnostics();local c=HP.ForeverCoverage()
 print('Forever index: '..c.indexed..' quests; '..c.zephras..' Zephras records; '..c.located..' pickup locations; '..c.pending..' still need availability/navigation verification. Indexed does not mean fully routed.')
end
local create=HP.CreateUI
function HP.CreateUI()
 create();HP.ResolveForeverMaps()
 for id,fact in pairs(HP.db.observedQuestFacts or {}) do
  if type(fact)=='table' and type(fact.name)=='string' and HP.questData[id] then HP.questData[id].name=fact.name end
 end
 local f=CreateFrame('Frame',nil,UIParent);HP.foreverEvents=f
 for _,event in ipairs({'GOSSIP_SHOW','GOSSIP_CLOSED','QUEST_ACCEPTED','QUEST_TURNED_IN','QUEST_REMOVED','ZONE_CHANGED_NEW_AREA'}) do pcall(f.RegisterEvent,f,event) end
 f:SetScript('OnEvent',function(_,event)
  if event=='GOSSIP_SHOW' then HP.ObserveQuestOffers()
  elseif event~='GOSSIP_CLOSED' then HP.liveQuestOffers={} end
 end)
end
