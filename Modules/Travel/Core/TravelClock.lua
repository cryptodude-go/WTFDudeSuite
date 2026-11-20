local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'travel',function(...)
-- Lightweight, local travel clocks. No party broadcasts and no stale server epochs.
-- Recorded route geometry/times: DockWatch (MIT), see Licenses/DockWatch-MIT.txt.
local _,HP=...
local D=HP.Native
local C,T,P,UI,Cfg=D.Compat,D.Travel,D.Panel,D.UI,D.Config
local V={clocks={},routes=HP.TransportData.DW.BUILTIN_PATHS};HP.TravelClock=V
local function now()return GetTime()end
local function settings()
 D.db.ui.travelClock=D.db.ui.travelClock or {enabled=true,docks=true}
 return D.db.ui.travelClock
end
local function duration(seconds)
 seconds=math.max(0,math.ceil(seconds));return string.format('%dm %02ds',math.floor(seconds/60),seconds%60)
end
local function position()
 if type(UnitPosition)~='function'then return end
 local ok,n,w,_,instance=pcall(UnitPosition,'player')
 if not ok then return end
 n,w,instance=C.Plain(n),C.Plain(w),C.Plain(instance)
 if type(n)=='number' and type(w)=='number' and type(instance)=='number' then return n,w,instance end
end
function V:NearestDock()
 local n,w,instance=position();if not n then return end
 local route,side,dist
 for _,r in ipairs(self.routes)do
  for _,s in ipairs({'a','b'})do
   local p=r[s]
   if p and p[1]==instance then
    local d=(p[2]-n)^2+(p[3]-w)^2
    if d<180^2 and (not dist or d<dist)then route,side,dist=r,s,d end
   end
  end
 end
 return route,side
end
function V:SelectedDock()
 if self.selected then
  for _,r in ipairs(self.routes)do if r.id==self.selected then return r,self.side or 'a' end end
 end
 return self:NearestDock()
end
function V:Observe(r,side,arriving)
 if not r or not r.base.loop then return end
 local wait=r.base[side=='a' and 'wa' or 'wb'] or 0
 self.clocks[r.id]={depart=now()+(arriving and wait or 0),side=side,observed=now(),source='observed'}
 self:Tick()
end
function V:DockText(r,side)
 if not r then return 'Move near a dock, or choose a route below.' end
 local name=(r.names or r.places)[side=='a' and 1 or 2]
 local clock=self.clocks[r.id];local base=r.base
 if not clock or now()-clock.observed>math.min(1200,base.loop*3)then
  return name..': schedule not synchronized. Mark an arrival or departure.'
 end
 local depart=clock.depart
 if side~=clock.side then
  local leg=base[clock.side=='a' and 'ab' or 'ba']
  if not leg then return name..': this leg has no verified timing.' end
  depart=depart+leg+(base[side=='a' and 'wa' or 'wb'] or 0)
 end
 local untilDeparture=(depart-now())%base.loop
 if untilDeparture<.01 and depart<=now() then untilDeparture=base.loop end
 local wait=base[side=='a' and 'wa' or 'wb'] or 0
 if untilDeparture<=wait then return name..': departs in ~'..duration(untilDeparture)end
 return name..': arrives in ~'..duration(untilDeparture-wait)
end
-- Project onto consecutive points in the SAME instance. Never draw a segment across a loading screen.
function V:Project(path,n,w,instance)
 local best,elapsed
 for i=2,#path do
  local a,b=path[i-1],path[i]
  if a[2]==instance and b[2]==instance then
   local dn,dw=b[3]-a[3],b[4]-a[4];local length=dn*dn+dw*dw
   if length>0 then
    local fraction=math.max(0,math.min(1,((n-a[3])*dn+(w-a[4])*dw)/length))
    local d=(n-a[3]-fraction*dn)^2+(w-a[4]-fraction*dw)^2
    if not best or d<best then best=d;elapsed=a[1]+fraction*(b[1]-a[1])end
   end
  end
 end
 return elapsed,best
end
function V:TrackTransport()
 local n,w,instance=position();if not n then self.samples=nil;return end
 local stamp=now();local speed=C.Plain(HP.Call(GetUnitSpeed,'player'))
 local samples={};local chosen
 for _,r in ipairs(self.routes)do
  for _,dir in ipairs({'ab','ba'})do
   if r[dir]then
    local progress,distance=self:Project(r[dir],n,w,instance)
    local limit=r.base[dir]
    if distance and distance<24^2 and limit and progress>4 and progress<limit-4 then
     local key=r.id..':'..dir;local old=self.samples and self.samples[key];local count=1
     if old then
      local dt=stamp-old.t;local dp=progress-old.progress
      -- Require movement at the transport's recorded speed, while the player is idle.
      if dt>0 and dt<1.6 and dp>dt*.5 and dp<dt*1.8 and type(speed)=='number' and speed<.5 then count=old.count+1 end
     end
     local sample={route=r,dir=dir,progress=progress,t=stamp,count=count,distance=distance}
     samples[key]=sample
     if not chosen or count>chosen.count or count==chosen.count and distance<chosen.distance then chosen=sample end
    end
   end
  end
 end
 self.samples=samples;self.candidate=chosen
 if chosen and chosen.count>=4 then
  local r,dir=chosen.route,chosen.dir
  self.clocks[r.id]={depart=stamp-chosen.progress,side=dir=='ab' and 'a' or 'b',observed=stamp,source='ride'}
  self.ride={route=r,dir=dir,finish=stamp+(r.base[dir]-chosen.progress),seen=stamp}
 end
end
function V:CaptureFlight(index)
 local from,to,name,fromName
 for _,node in ipairs(T.taxiNodes or {})do
  if node.state=='current'then from=node.npc or (node.name and 'name:'..node.name);fromName=node.name end
  if node.index==index then to=node.npc or (node.name and 'name:'..node.name);name=node.name end
 end
 local f=T.flight
 from=from or f and f.from;to=to or f and f.to
 self.pending={from=from,to=to,name=name,fromName=fromName,requested=now()}
end
function V:FlightText()
 local f=self.flight;if not f then return end
 local elapsed=now()-f.start
 if f.seconds and elapsed<f.seconds then return 'Flight: '..(f.name or 'destination')..' · ~'..duration(f.seconds-elapsed)..' remaining'end
 return 'Flight: '..duration(elapsed)..' elapsed'..(f.seconds and ' · arrival soon' or ' · learning route time')
end
function V:DisplayState()
 if HP.Suite and not HP.Suite:On('travel') then return end
 if not D.db or not settings().enabled then return end
 local f=self.flight
 if f and not C.OnTaxi() then return end
 if f then
  local elapsed=math.max(0,now()-f.start)
  return {kind='flight',phase='flight',destination=f.name or 'Flight destination',origin=f.fromName,
   elapsed=elapsed,total=f.seconds,remaining=f.seconds and math.max(0,f.seconds-elapsed),
   overdue=f.seconds and elapsed>f.seconds,estimated=true}
 end
 local ride=self.ride
 if ride and now()-ride.seen<4 then
  local r=ride.route;local names=r.names or r.places;local ab=ride.dir=='ab'
  local total=r.base[ride.dir];local remaining=math.max(0,ride.finish-now())
  return {kind=r.vehicle=='zeppelin' and 'zeppelin' or 'boat',phase='ride',destination=names[ab and 2 or 1],
   origin=names[ab and 1 or 2],remaining=remaining,total=total,elapsed=math.max(0,total-remaining),estimated=true}
 end
 if not settings().docks then return end
 local r,side=self:NearestDock();if not r then return end
 local names=r.names or r.places;local base=r.base
 local state={kind=r.vehicle=='zeppelin'and 'zeppelin'or 'boat',phase='unsynced',origin=names[side=='a'and 1 or 2],destination=names[side=='a'and 2 or 1],estimated=true}
 local clock=self.clocks[r.id]
 if not clock or now()-clock.observed>math.min(1200,base.loop*3)then return state end
 local depart=clock.depart
 if side~=clock.side then
  local leg=base[clock.side=='a'and 'ab'or 'ba'];if not leg then return state end
  depart=depart+leg+(base[side=='a'and 'wa'or 'wb']or 0)
 end
 local left=(depart-now())%base.loop
 if left<.01 and depart<=now()then left=base.loop end
 local wait=base[side=='a'and 'wa'or 'wb']or 0
 state.phase=left<=wait and 'boarding'or 'waiting'
 state.remaining=left<=wait and left or left-wait
 state.total=left<=wait and wait or base.loop-wait
 state.elapsed=math.max(0,state.total-state.remaining)
 return state
end
function V:Tick()
 if not D.db then return end
 local cfg=settings()
 local taxi=C.OnTaxi()
 if taxi then self.landedAt=nil end
 if taxi and not self.flight then
  local p=self.pending
  if p and now()-p.requested>45 then p=nil;self.pending=nil end
  local native=T.flight
  p=p or native or {}
  local key=p.from and p.to and tostring(p.from)..':'..tostring(p.to)
  local known=key and D.db.flightTimes and D.db.flightTimes[key]
  if HP.FlightInsights and p.routeKey then known=HP.FlightInsights:Known(p.routeKey) end
  self.flight={routeKey=p.routeKey,invalid=p.invalid,from=p.from,to=p.to,name=p.name,fromName=p.fromName,start=now(),seconds=known and known.seconds,nativeRecorded=native and native.from==p.from and native.to==p.to and native.from~=nil and true or false}
 elseif not taxi and self.flight then
  self.landedAt=self.landedAt or now()
  if now()-self.landedAt<.8 then self.text=nil;return end
  self.lastLanding=self.landedAt
  local f=self.flight;local elapsed=self.lastLanding-f.start
  -- Native Travel already records its own routes; only fill a missing observation.
  if not f.invalid and f.from and f.to and elapsed>5 and elapsed<3600 then
   local key=tostring(f.from)..':'..tostring(f.to)
   if not f.nativeRecorded then T:RecordFlight(f.from,f.to,elapsed)end
  end
  self.flight=nil;self.pending=nil
 end
 if not taxi then self:TrackTransport()end
 local text=cfg.enabled and self:FlightText() or nil
 if cfg.enabled and not text and self.ride and now()-self.ride.seen<4 then
  local ride=self.ride;local r=ride.route
  text=(r.vehicle=='zeppelin' and 'Zeppelin' or 'Boat')..' to '..(r.names or r.places)[ride.dir=='ab' and 2 or 1]..' · ~'..duration(ride.finish-now())
 end
 if cfg.enabled and not text and cfg.docks then local r,s=self:NearestDock();if r then text=self:DockText(r,s)end end
 self.text=text
end
local page={key='dudeTravel',title='Flight, boat and zeppelin timers'}
page.build=function(canvas,width)
 local cfg=settings()
 local result={
 UI.CheckRow(canvas,Cfg,{label='Show travel timers',default=true,get=function()return cfg.enabled end,set=function(v)cfg.enabled=v;if not v and HP.TravelDisplay then HP.TravelDisplay.previewUntil=nil end;V:Tick();P:Update()end},width),
 UI.CheckRow(canvas,Cfg,{label='Show next transport near docks',default=true,get=function()return cfg.docks end,set=function(v)cfg.docks=v;V:Tick()end},width),
 UI.HeaderRow(canvas,'Boat / zeppelin route',width),
 UI.DropdownRow(canvas,Cfg,{label='Boat / zeppelin route',items=function()
  local choices={{value='auto',text='Automatic: nearest dock'}}
  for _,r in ipairs(V.routes)do choices[#choices+1]={value=r.id,text=table.concat(r.names or r.places,' - ')}end
  return choices
 end,get=function()return V.selected or 'auto'end,set=function(v)V.selected=v~='auto' and v or nil end},width),
 UI.HeaderRow(canvas,'Dock / direction',width),
 UI.DropdownRow(canvas,Cfg,{label='Dock / direction',items=function()
  local r=V:SelectedDock();return {{value='a',text=r and (r.names or r.places)[1] or 'First dock'},{value='b',text=r and (r.names or r.places)[2] or 'Second dock'}}
 end,get=function()local _,s=V:SelectedDock();return s or 'a'end,set=function(v)
  local r=V:SelectedDock();if r then V.selected=r.id;V.side=v end
 end},width),
 UI.ButtonRow(canvas,Cfg,{label='Transport just arrived',desc='Synchronize this dock when you see it arrive.',button='Arrived',run=function()local r,s=V:SelectedDock();V:Observe(r,s,true)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Transport just departed / I missed it',desc='Start the countdown to the next visit.',button='Departed',run=function()local r,s=V:SelectedDock();V:Observe(r,s,false)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Current dock status',desc=V:DockText(V:SelectedDock()),button='Refresh',run=function()Cfg:OpenPage(page)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Clear transport synchronization',desc='Use after changing layers. Unsynchronized clocks show no invented countdown.',button='Clear',run=function()V.clocks={};V.ride=nil;V.candidate=nil;V.samples=nil;V:Tick()end},width)}
 return result
end
HP.nativeTravelPage=page
local build=Cfg.TABS[Cfg.TAB.guide or 1].build
Cfg.TABS[Cfg.TAB.guide or 1].build=function(canvas,width)
 local result=build(canvas,width)
 if HP.Suite then return result end
 result[#result+1]=UI.ButtonRow(canvas,Cfg,{label='Travel timers',desc='Flights, boats, zeppelins and missed departures.',button='Open',run=function()Cfg:OpenPage(page)end},width)
 return result
end
local command=SlashCmdList.DUDEWHERESMYDING
SlashCmdList.DUDEWHERESMYDING=function(input)
 if(input or ''):lower():match('^%s*travel%s*$')then Cfg:Open('guide');Cfg:OpenPage(page);return end
 return command(input)
end
if type(hooksecurefunc)=='function'then
 if type(TakeTaxiNode)=='function'then pcall(hooksecurefunc,'TakeTaxiNode',function(i)V:CaptureFlight(i)end)end
 if C_TaxiMap and type(C_TaxiMap.TakeTaxiNode)=='function'then pcall(hooksecurefunc,C_TaxiMap,'TakeTaxiNode',function(i)V:CaptureFlight(i)end)end
end
D:On('PLAYER_ENTERING_WORLD',function()V.clocks={};V.candidate=nil;V.samples=nil;V.ride=nil end)
D:On('ZONE_CHANGED_NEW_AREA',function()V.candidate=nil;V.samples=nil end)
local ticker=CreateFrame('Frame');local elapsed=0
V.ticker=ticker
ticker:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed>=.5 then elapsed=0;D:Safe(V.Tick,V)end
end)

end)
