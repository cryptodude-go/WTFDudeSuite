local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'travel',function(...)
-- Flight-master previews and context/path-specific measurements. Independent implementation.
local _,HP=...
local D=HP.Native;local T,V,B=D.Travel,HP.TravelClock,HP.TravelDisplay
local F={routes={},pins=setmetatable({},{__mode='k'})};HP.FlightInsights=F
local function call(fn,...)return HP.Call(fn,...)end
local function key(parts)
 local out={};for _,v in ipairs(parts)do v=tostring(v);out[#out+1]=#v..':'..v end;return table.concat(out,'|')
end
local function duration(n)return string.format('%d:%02d',math.floor(n/60),math.floor(n%60))end
function F:Context()
 return key({call(GetRealmName)or '',call(UnitFactionGroup,'player')or '',call(GetLocale)or ''})
end
function F:DB()
 D.db.flightInsights=D.db.flightInsights or {routes={},contexts={}}
 local db=D.db.flightInsights;db.routes=db.routes or {};db.contexts=db.contexts or {}
 local context=self:Context()
 if self.context~=context then
  if not db.legacyImported then
   db.contexts[context]=D.db.flightTimes or {};db.legacyImported=true
  end
  db.contexts[context]=db.contexts[context]or {}
  D.db.flightTimes=db.contexts[context];self.context=context
 end
 return db
end
function F:Known(routeKey)
 local e=routeKey and self:DB().routes[routeKey]
 if type(e)=='table' and type(e.seconds)=='number' and e.seconds==e.seconds and e.seconds>=2 and e.seconds<7200 then return e end
end
function F:Snapshot()
 self:DB();self.routes={};local nodes=T.taxiNodes or {};local indexed,origin={}
 for _,n in ipairs(nodes)do if n.index then indexed[n.index]=n;if n.state=='current'then origin=n end end end
 if not origin then return end
 local function nodeKey(n)return key({n.npc or n.name or '',n.x or '',n.y or ''})end
 for _,n in ipairs(nodes)do if n.state=='known' then
  local parts={self.context,call(GetTaxiMapID)or '',nodeKey(origin)}
  local count=call(GetNumRoutes,n.index);local valid=true
  if type(count)=='number' and count>0 and type(TaxiGetNodeSlot)=='function' then
   local previous=origin.index
   for segment=1,math.min(count,100)do
    local from=call(TaxiGetNodeSlot,n.index,segment,true);local dest=call(TaxiGetNodeSlot,n.index,segment,false)
    if from~=previous or not indexed[dest]then valid=false;break end
    parts[#parts+1]=nodeKey(indexed[dest]);previous=dest
   end
   valid=valid and previous==n.index and count<=100
  elseif count~=nil then valid=false
  else parts[#parts+1]='endpoints' end
  parts[#parts+1]=nodeKey(n)
  if valid then self.routes[n.index]={key=key(parts),from=origin.name,to=n.name}end
 end end
end
function F:Hover(index)
 self.hoverIndex=index
 if not D.db or not HP.Suite:On('travel') or B:Settings().flightPreview==false or D.Compat.OnTaxi()then return end
 local route=self.routes[index];if not route then return end
 local known=self:Known(route.key)
 self.hover={kind='flight',phase='flight',origin=route.from,destination=route.to,total=known and known.seconds,
 remaining=known and known.seconds,elapsed=0,flightMaster=true}
 if GameTooltip and GameTooltip:IsShown() and self.tooltipRoute~=route.key then
  self.tooltipRoute=route.key
  GameTooltip:AddLine('WTF! DUDE SUITE · Flight time',1,.82,.25)
  GameTooltip:AddLine(known and ('~'..duration(known.seconds)..' · '..(known.count or 1)..' measurement(s)')or 'Not measured yet · complete this route once',.85,.85,.8,true)
  GameTooltip:Show()
 end
 B:Update()
end
function F:Leave()self.hoverIndex=nil;self.hover=nil;self.tooltipRoute=nil;B:Update()end
local capture=V.CaptureFlight
function V:CaptureFlight(index)
 F.invalidFlight=nil;capture(self,index)
 if self.pending then local route=F.routes[index];self.pending.routeKey=route and route.key end
 F.hover=nil;B.previewUntil=nil
end
local record=T.RecordFlight
function T:RecordFlight(...)
 if F.invalidFlight then return end
 if D.db then F:DB()end
 return record(self,...)
end
local tick=V.Tick
function V:Tick()
 local before=self.flight
 local result=tick(self)
 if before and not self.flight and before.routeKey and not before.invalid and not F.invalidFlight then
  local seconds=(self.lastLanding or GetTime())-before.start
  if seconds>=2 and seconds<=7200 then
   local routes=F:DB().routes;local old=F:Known(before.routeKey)
   routes[before.routeKey]={seconds=old and (old.seconds*.7+seconds*.3)or seconds,count=math.min(1000,(old and old.count or 0)+1)}
  end
 end
 return result
end
local state=B.State
function B:State()
 if F.hover and not D.Compat.OnTaxi() and self:Settings().flightPreview~=false then return F.hover end
 return state(self)
end
local model=B.Model
function B:Model(state)
 local m=model(self,state)
 if m and state.flightMaster then
  m.label='FLIGHT MASTER · '..(state.origin or '')
  m.clock=state.total and duration(state.total)or '--:--';m.caption='estimated duration'
  m.detail=state.total and 'Measured on this route' or 'Not measured yet · fly this route to learn it'
  m.source='Realm, faction, language and route-specific measurement'
 end
 return m
end
local function hook(name,fn)if type(_G[name])=='function' and type(hooksecurefunc)=='function'then pcall(hooksecurefunc,name,fn)end end
local function bind(pin,index)
 if not pin or F.pins[pin]or type(pin.HookScript)~='function'then return end
 F.pins[pin]=true
 pin:HookScript('OnEnter',function(self)
  local id=self.taxiNodeData and self.taxiNodeData.slotIndex or call(self.GetID,self)or index
  F:Hover(id)
 end)
 pin:HookScript('OnLeave',function()F:Leave()end)
end
function F:HookPins()
 for _,n in ipairs(T.taxiNodes or {})do bind(_G['TaxiButton'..n.index],n.index)end
 local map=FlightMapFrame
 if map and type(map.EnumeratePinsByTemplate)=='function'then pcall(function()
  local count=0;for pin in map:EnumeratePinsByTemplate('FlightMap_FlightPointPinTemplate')do bind(pin);count=count+1;if count>250 then break end end
 end)end
end
D:On('PLAYER_LOGIN',function()
 F:DB()
 hook('TaxiNodeOnButtonEnter',function(button)F:Hover(type(button)=='number' and button or call(button and button.GetID,button))end)
 hook('TaxiNodeOnButtonLeave',function()F:Leave()end)
 hook('TaxiRequestEarlyLanding',function()F.invalidFlight=true;if V.flight then V.flight.invalid=true end;if V.pending then V.pending.invalid=true end end)
end)
D:On('TAXIMAP_OPENED',function()F.open=true;F:Snapshot();F:HookPins()end)
D:On('TAXIMAP_CLOSED',function()F.open=false;F:Leave()end)
D:On('PLAYER_CONTROL_GAINED',function()V:Tick();B:Update()end)
local ticker=CreateFrame('Frame');local elapsed=0
 ticker:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<.5 then return end;elapsed=0
 if F.open then
  if not T.taxiNodes or #T.taxiNodes==0 then T:LearnTaxi()end
  F:Snapshot();F:HookPins();if F.hoverIndex then F:Hover(F.hoverIndex)end
 end
end)

end)
