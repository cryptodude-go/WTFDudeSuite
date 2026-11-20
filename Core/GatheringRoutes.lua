local _,HP=...
-- Independently authored Thendal surface corridor; never presented as node data.
HP.gatherLoops[2521]={{.427,.237},{.44,.25},{.456,.27},{.47,.30},{.451,.322},{.425,.30},{.415,.265},{.427,.237}}
HP.gatherGuideZones={Mining={[1]={1411,1412,1420,2521},[65]={1413,1440,1424},[125]={1417,1443,1441},[175]={1425,1446},[245]={1449,1419,1448},[275]={1452,1451,1449}},Herbalism={[1]={1411,1412,1420,2521},[70]={1413,1421},[115]={1424,1442},[170]={1434,1417},[205]={1446,1427},[230]={1425},[270]={1448,1452}}}
local function suitableGuideZone(task,map)
 local bands=HP.gatherGuideZones[task.book.name] or {};local from=task.step and task.step.from
 local manual=HP.db and HP.db.gatherResource
 for band,maps in pairs(bands) do
  local applies=band==from
  if manual then applies=false;for _,id in ipairs(HP.gatherBands[task.book.name][band] or {}) do if id==manual then applies=true end end end
  if applies then for _,id in ipairs(maps) do if id==map then return true end end end
 end
end
function HP.GatherCurrentMap()
 local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player');local first=map
 for _=1,6 do
  if HP.gatherSeeds[map] then return map end
  for _,z in ipairs(HP.zoneCatalog) do if z.mapID==map then return map end end
  local info=map and HP.Call(C_Map.GetMapInfo,map);if not info or not info.parentMapID or info.parentMapID==0 or info.parentMapID==map then break end;map=info.parentMapID
 end
 return first
end
function HP.GatherPosition(map)
 map=map or HP.GatherCurrentMap()
 local p=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,'player');local x,y;if p then x,y=HP.Call(p.GetXY,p) end
 if type(x)=='number' and type(y)=='number' and x>0 and x<1 and y>0 and y<1 then return {mapID=map,x=x,y=y} end
end
local function sq(a,b,w,h) return ((a.x-b.x)*w)^2+((a.y-b.y)*h)^2 end
local function dimensions(map)
 local w,h=HP.Call(C_Map and C_Map.GetMapWorldSize,map)
 return type(w)=='number' and w>0 and w or 5000,type(h)=='number' and h>0 and h or 3333
end
-- Retry delays are search policy, not predictions of server respawn times.
local CHECK_RETRY,HARVEST_RETRY=180,600
function HP.GatherClock() return HP.Call(time) or HP.Call(GetTime) or 0 end
function HP.GatherVisitExpiry(p,kind)
 local stamp=HP.GatherClock();local expiry;local w,h=dimensions(p.mapID)
 for _,v in ipairs(HP.db.gatherVisits and HP.db.gatherVisits[p.mapID] or {}) do
  local untilAt=v.at+(v.harvested and HARVEST_RETRY or CHECK_RETRY)
  if v.kind==kind and untilAt>stamp and sq(p,v,w,h)<20^2 then expiry=math.max(expiry or 0,untilAt) end
 end
 -- Existing harvest history also survives a reload/update, without any migration of live files.
 for _,v in ipairs(HP.db.gatherNodes and HP.db.gatherNodes[p.mapID] or {}) do
  local info=HP.gatherNodeInfo[v.id];local untilAt=(v.last or 0)+HARVEST_RETRY
  if info and info.kind==kind and untilAt>stamp and sq(p,v,w,h)<20^2 then expiry=math.max(expiry or 0,untilAt) end
 end
 return expiry
end
function HP.MarkGatherVisit(pos,kind,harvested)
 if not HP.db or not pos or not pos.mapID or type(pos.x)~='number' or type(pos.y)~='number' or (kind~='Mining' and kind~='Herbalism') then return end
 local stamp=HP.GatherClock();local w,h=dimensions(pos.mapID)
 HP.db.gatherVisits=HP.db.gatherVisits or {};local visits=HP.db.gatherVisits[pos.mapID] or {};HP.db.gatherVisits[pos.mapID]=visits
 for i=#visits,1,-1 do local v=visits[i];if v.at+(v.harvested and HARVEST_RETRY or CHECK_RETRY)<=stamp then table.remove(visits,i) end end
 local entry
 for _,v in ipairs(visits) do if v.kind==kind and sq(pos,v,w,h)<20^2 then entry=v;break end end
 if entry then
  if not harvested then return end
  entry.at=stamp;entry.harvested=true
 else visits[#visits+1]={x=pos.x,y=pos.y,kind=kind,at=stamp,harvested=harvested==true} end
 if #visits>256 then table.remove(visits,1) end
 HP.gatherPreviousWaypoint={mapID=pos.mapID,x=pos.x,y=pos.y,kind=kind}
 HP.gatherVisitRevision=(HP.gatherVisitRevision or 0)+1;HP.gatherRouteCache={};HP.activeGatherRoute=nil;HP.gatherRouteDirty=true
 return true
end
function HP.GatherAllowed(task)
 local ids={};local name=task.book.name
 local manual=HP.db and HP.db.gatherResource
 if manual and HP.gatherNodeInfo[manual] and HP.gatherNodeInfo[manual].kind==name then ids={manual}
 else ids=HP.gatherBands[name] and HP.gatherBands[name][task.step and task.step.from or 0] or {} end
 local allowed,key={},{}
 for _,id in ipairs(ids) do local info=HP.gatherNodeInfo[id];if info and info.min<=task.rank and task.rank<(info.gray or info.min+100) then allowed[id]=true;key[#key+1]=id end end
 table.sort(key);return allowed,table.concat(key,',')
end
function HP.GatherMapNodes(map,task)
 local allowed,key=HP.GatherAllowed(task);local cacheKey=tostring(map)..':'..key..':'..tostring(HP.gatherRevision or 0)
 HP.gatherNodeCache=HP.gatherNodeCache or {};if HP.gatherNodeCache[cacheKey] then return HP.gatherNodeCache[cacheKey] end
 local nodes={};local w,h=dimensions(map)
 local function add(x,y,id,observed,source)
  if not allowed[id] then return end
  for _,p in ipairs(nodes) do if p.id==id and sq(p,{x=x,y=y},w,h)<15^2 then if observed then p.observed=true end;return end end
  nodes[#nodes+1]={mapID=map,x=x,y=y,id=id,observed=observed,source=source}
 end
 for _,p in ipairs(HP.gatherSeeds[map] or {}) do add(p[1],p[2],p[3],false,p[4]==1 and 'Forever reference' or p[4]==3 and 'Classic gathering database' or 'Classic reference') end
 for _,p in ipairs(HP.db and HP.db.gatherNodes and HP.db.gatherNodes[map] or {}) do add(p.x,p.y,p.id,true,'Gathered by you') end
 local count=0;for _ in pairs(HP.gatherNodeCache)do count=count+1 end
 if count>=8 then HP.gatherNodeCache={}end
 HP.gatherNodeCache[cacheKey]=nodes;return nodes
end
local function nearestOrder(nodes,start,w,h)
 local result,used={},{};local at=start
 for _=1,math.min(32,#nodes) do
  local index,best
  for i,p in ipairs(nodes) do if not used[i] then local d=sq(at,p,w,h);if not best or d<best then index,best=i,d end end end
  if not index then break end;used[index]=true;result[#result+1]=nodes[index];at=nodes[index]
 end
 return result
end
function HP.GatherRoute(task,map)
 local _,key=HP.GatherAllowed(task);if key=='' then return end;local cacheKey=task.book.name..':'..key..':'..tostring(map)..':'..tostring(HP.gatherRevision or 0)..':'..tostring(HP.gatherVisitRevision or 0)
 HP.gatherRouteCache=HP.gatherRouteCache or {}
 local cached=HP.gatherRouteCache[cacheKey];local stamp=HP.GatherClock()
 if cached and (not cached.expiresAt or cached.expiresAt>stamp) then return cached end
 local nodes={};for _,p in ipairs(HP.GatherMapNodes(map,task)) do nodes[#nodes+1]=p end
 if #nodes==0 then
  local corridor=HP.gatherLoops[map]
  local suitable=task.step and (map==task.step.mapID or suitableGuideZone(task,map))
  if corridor and suitable then local stops={};for i=1,#corridor-1 do stops[#stops+1]={mapID=map,x=corridor[i][1],y=corridor[i][2]} end
   local fallback={mapID=map,nodes=stops,points=corridor,key=cacheKey,suggested=true,source='Suggested surface circuit; node positions not indexed'}
   HP.gatherRouteCache[cacheKey]=fallback;return fallback
  end
  return
 end
 local w,h=dimensions(map);local start=map==HP.GatherCurrentMap() and HP.GatherPosition(map)
 local old=HP.gatherLoops[map];start=start or {x=old and old[1][1] or .5,y=old and old[1][2] or .5}
 local available,expiry={},nil
 for _,p in ipairs(nodes) do
  local untilAt=HP.GatherVisitExpiry(p,task.book.name)
  if untilAt then expiry=math.min(expiry or untilAt,untilAt) else available[#available+1]=p end
 end
 if #available==0 then
  local waiting={mapID=map,nodes={},points={},key=cacheKey,waiting=true,expiresAt=expiry,source='Recently checked locations'}
  HP.gatherRouteCache[cacheKey]=waiting;return waiting
 end
 table.sort(available,function(a,b) return sq(a,start,w,h)<sq(b,start,w,h) end)
 local cluster={};local anchor=available[1]
 for _,p in ipairs(available) do if sq(p,anchor,w,h)<=1800^2 then cluster[#cluster+1]=p end;if #cluster>=64 then break end end
 local ordered=nearestOrder(cluster,start,w,h);local points={}
 for _,p in ipairs(ordered) do points[#points+1]={p.x,p.y} end;points[#points+1]={points[1][1],points[1][2]}
 local route={mapID=map,nodes=ordered,points=points,key=cacheKey,expiresAt=expiry,source='Known possible node locations'}
 local count=0;for _ in pairs(HP.gatherRouteCache) do count=count+1 end;if count>16 then HP.gatherRouteCache={} end
 HP.gatherRouteCache[cacheKey]=route;return route
end
function HP.InvalidateGathering()
 HP.gatherRevision=(HP.gatherRevision or 0)+1;HP.gatherRouteCache={};HP.gatherNodeCache={};HP.activeGatherRoute=nil
end
local task=HP.ProfessionTask
function HP.ProfessionTask(name)
 if HP.Suite and not HP.Suite:ProfessionAllowed(name) then return end
 local t=task(name)
 local focus=HP.db and HP.gatherNodeInfo[HP.db.gatherResource]
 if focus and t and (focus.kind~=name or focus.min>t.rank or t.rank>=(focus.gray or focus.min+100)) then if name==HP.db.professionGuide then HP.db.gatherResource=nil end;focus=nil end
 if not t or (name~='Mining' and name~='Herbalism') or not t.step or t.training or t.complete then return t end
 local current=HP.GatherCurrentMap();local chosen=HP.db.gatherZone
 local route=type(chosen)=='number' and HP.GatherRoute(t,chosen) or nil
 if not route and (not chosen or chosen=='auto') then route=HP.GatherRoute(t,current) end
 route=route or HP.GatherRoute(t,t.step.mapID)
 if not route then
  local maps={};for map in pairs(HP.gatherSeeds) do maps[#maps+1]=map end;table.sort(maps)
  for _,map in ipairs(maps) do route=HP.GatherRoute(t,map);if route then break end end
 end
 if not route then return t end
 if not route.suggested and not route.waiting and current==route.mapID and HP.db.guideBook=='professions' and HP.db.professionGuide==name and not HP.db.paused and not HP.db.hidden and HP.db.autoWaypoint~=false and not HP.manualWaypoint then
  local pos=HP.GatherPosition(current);local changed;local w,h=dimensions(current)
  if pos then for _,p in ipairs(route.nodes) do if sq(p,pos,w,h)<8^2 then changed=HP.MarkGatherVisit(p,name,false) or changed end end end
  if changed then route=HP.GatherRoute(t,current) end
 end
 local s={};for k,v in pairs(t.step) do s[k]=v end;t.step=s
 local info=HP.Call(C_Map and C_Map.GetMapInfo,route.mapID);s.mapID=route.mapID;s.zone=info and info.name or s.zone
 t.gatherRoute=route
 if route.waiting then
  t.location=nil;t.gatherWaiting=true
  t.rows={{kind='info',text='Nearby spots recently checked. Waiting before checking again.',tooltipText='Checked spots are skipped for 3 minutes; harvested spots for 10 minutes. These are retry delays, not guaranteed respawn timers.'}}
  return t
 end
 t.location={mapID=route.mapID,x=route.points[1][1],y=route.points[1][2]}
 t.rows[1]={kind='travel',text=(current==route.mapID and 'Follow the gathering circuit in ' or 'Go to ')..s.zone..'.',tooltipText=route.suggested and 'Suggested surface circuit, not indexed node positions. Your gathered nodes appear as green circles.' or 'Preloaded possible spawn locations; no gathering history is needed. Check the nearest location, then follow the next waypoint even if the spot is empty. Enable Find Herbs / Find Minerals for live tracking. Terrain and caves can require detours.'}
 local names={};local allowed=HP.GatherAllowed(t);for id in pairs(allowed) do names[#names+1]=HP.gatherNodeInfo[id].name end;table.sort(names)
 t.rows[2]={kind='objective',text=table.concat(names,' / ')..' until skill '..math.min(s.to,t.maximum,focus and (focus.gray or focus.min+100) or 300)..'.',tooltipText='The route changes with your live profession skill. Train the next profession rank when your current cap is reached.'}
 return t
end
local draw=HP.DrawAuxiliaryGuide
function HP.DrawAuxiliaryGuide()
 draw()
 if HP.Call(InCombatLockdown)==true then return end
 local t=HP.auxTask;local r=t and t.gatherRoute
 if not r or not HP.auxiliaryActive or HP.db.guideBook~='professions' then return end
 if HP.activeGatherRoute~=r.key then
  HP.activeGatherRoute=r.key;HP.gatherMap=r.mapID
  if r.waiting then HP.gatherPoint=1;HP.waypoint=nil;HP.UpdateArrow();HP.UpdateMapPins();return end
  local index=1
  if r.suggested then
   local pos=r.mapID==HP.GatherCurrentMap() and HP.GatherPosition(r.mapID);local best;local w,h=dimensions(r.mapID)
   if pos then for i,p in ipairs(r.nodes) do local d=sq(pos,p,w,h);if not best or d<best then index,best=i,d end end end
   if best and best<30^2 then index=index%#r.nodes+1 end
  end
  HP.gatherPoint=index
  if HP.db.autoWaypoint~=false and not HP.manualWaypoint and not HP.db.paused and not HP.db.hidden then
   HP.waypoint={mapID=r.mapID,x=r.points[index][1],y=r.points[index][2]};HP.UpdateArrow();HP.UpdateMapPins()
  end
 end
end
function HP.MoveGatherStep(delta)
 local t=HP.auxTask;local r=t and t.gatherRoute
 if not r or r.suggested then return false end
 if delta>0 then
  if HP.waypoint then HP.MarkGatherVisit(HP.waypoint,t.book.name,false) end
  HP.manualWaypoint=nil;HP.Refresh()
 elseif HP.gatherPreviousWaypoint and HP.gatherPreviousWaypoint.kind==t.book.name and HP.gatherPreviousWaypoint.mapID==r.mapID then
  local p=HP.gatherPreviousWaypoint;HP.manualWaypoint={mapID=p.mapID,x=p.x,y=p.y};HP.Refresh()
 end
 return true
end
function HP.TickGatherRoute()
 local t=HP.auxTask
 if not HP.auxiliaryActive or not t or not t.gatherRoute or HP.db.paused or HP.db.hidden or HP.manualWaypoint then return end
 if HP.gatherLastMap~=HP.GatherCurrentMap() then HP.gatherLastMap=HP.GatherCurrentMap();HP.Refresh();return end
 if HP.db.autoWaypoint==false then return end
 if HP.gatherRouteDirty or t.gatherRoute.expiresAt and t.gatherRoute.expiresAt<=HP.GatherClock() then HP.gatherRouteDirty=nil;HP.Refresh();return end
 local dx,dy;if HP.waypoint then dx,dy=HP.NavigationVector(HP.waypoint) end
 if dx and math.sqrt(dx*dx+dy*dy)<(t.gatherRoute.suggested and 30 or 8) then HP.Refresh() end
end
