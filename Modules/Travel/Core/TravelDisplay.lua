local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'travel',function(...)
-- Compact, independent travel display. No code/media from external timer addons.
local _,HP=...
local D=HP.Native
local V,C,UI,Cfg=HP.TravelClock,D.Compat,D.UI,D.Config
local B={};HP.TravelDisplay=B
local DEFAULTS={style='classic',width=360,scale=100,opacity=88,locked=false,progress=true,countup=false,followTheme=true,flightPreview=true}
function B:Settings()
 D.db.ui.travelClock=D.db.ui.travelClock or {enabled=true,docks=true}
 local cfg=D.db.ui.travelClock
 for key,value in pairs(DEFAULTS)do if cfg[key]==nil then cfg[key]=value end end
 return cfg
end
local function clamp(n,lo,hi,default)
 n=tonumber(n)or default;return math.max(lo,math.min(hi,n))
end
local function clock(seconds)
 seconds=math.max(0,math.ceil(tonumber(seconds)or 0))
 return string.format('%d:%02d',math.floor(seconds/60),seconds%60)
end
local function epoch()
 local t=HP.Call(GetServerTime)
 if type(t)~='number'then t=HP.Call(time)end
 return type(t)=='number'and t or nil
end
local function eta(seconds)
 local stamp=epoch()
 if stamp and type(date)=='function'then
  local result=HP.Call(date,'%H:%M',stamp+math.ceil(seconds))
  return type(result)=='string'and result or nil
 end
end
-- Preserve the full flight across /reload, without learning the short remainder
-- as a complete trip. Transport schedules still expire/reset on layer changes.
local tick=V.Tick
function V:Tick()
 if not D.db then return end
 local saved=D.char and D.char.travelFlight
 if C.OnTaxi()and not self.flight and not self.pending and type(saved)=='table'then
  local stamp=epoch();local elapsed=stamp and type(saved.started)=='number'and stamp-saved.started
  if elapsed and elapsed>=0 and elapsed<3600 then
   self.flight={from=saved.from,to=saved.to,name=saved.name,fromName=saved.fromName,
    seconds=saved.seconds,routeKey=saved.routeKey,invalid=saved.invalid,start=GetTime()-elapsed,nativeRecorded=false}
  end
 end
 tick(self)
 if D.char then
  local f=self.flight;local stamp=epoch()
  if f and stamp then
   D.char.travelFlight={from=f.from,to=f.to,name=f.name,fromName=f.fromName,seconds=f.seconds,routeKey=f.routeKey,invalid=f.invalid,
    started=stamp-math.max(0,GetTime()-f.start)}
  elseif not C.OnTaxi()then D.char.travelFlight=nil end
 end
 if B.frame then B:Update()end
end
function B:Model(state)
 if not state then return end
 local cfg=self:Settings();local total=tonumber(state.total)
 if total and total<=0 then total=nil end
 local remaining=state.remaining and math.max(0,state.remaining)
 local elapsed=math.max(0,state.elapsed or 0)
 local labels={flight='FLIGHT',boat='BOAT',zeppelin='ZEPPELIN'}
 local m={kind=state.kind,label=labels[state.kind]or 'TRAVEL',title=state.destination or 'Destination',
  route=(state.origin and state.origin..' -> 'or '')..(state.destination or 'Destination'),
  progress=total and clamp(((cfg.countup and (state.phase=='flight'or state.phase=='ride'))and elapsed or remaining or 0)/total,0,1,0)or nil,
  source=state.estimated and 'Estimated timing' or 'Measured timing'}
 if state.phase=='unsynced'then
  m.label=m.label..' · DOCK';m.clock='--:--';m.caption='not synced';m.detail='Right-click to synchronize this dock';m.progress=nil
 elseif state.phase=='boarding'then
  m.label=m.label..' · BOARDING';m.clock=clock(remaining);m.caption='departs in';m.detail=state.origin or 'At the dock'
 elseif state.phase=='waiting'then
  m.label=m.label..' · NEXT ARRIVAL';m.clock=clock(remaining);m.caption='arrives in';m.detail=state.origin or 'Waiting at dock'
 elseif not total then
  m.clock=clock(elapsed);m.caption='elapsed';m.detail='Learning route time';m.source='No known duration';m.progress=nil
 elseif state.overdue then
  m.clock='+'..clock(elapsed-total);m.caption='over estimate';m.detail='Still travelling · timing this route';m.progress=cfg.countup and 1 or 0
 else
  m.clock=clock(cfg.countup and elapsed or remaining);m.caption=cfg.countup and 'elapsed'or 'remaining'
  local arrives=remaining and eta(remaining)
  m.detail=arrives and ('Arrival ~'..arrives..' · '..clock(total)..' total')or ('~'..clock(total)..' total')
 end
 if (state.phase=='flight'or state.phase=='ride')and state.origin then m.label=m.label..' · '..state.origin end
 if state.preview then m.label='PREVIEW · '..m.label end
 return m
end
function B:State()
 local state=V:DisplayState()
 if state then return state end
 if self.previewUntil and GetTime()<self.previewUntil then
  local horde=UnitFactionGroup('player')=='Horde'
  return {kind='flight',phase='flight',origin=horde and 'Orgrimmar'or 'Stormwind',
   destination=horde and 'The Crossroads'or 'Sentinel Hill',total=120,elapsed=48,remaining=72,estimated=true,preview=true}
 end
 self.previewUntil=nil
end
function B:Create()
 if self.frame then return end
 local f=CreateFrame('Frame','DudeDingTravelTimer',UIParent,'BackdropTemplate');self.frame=f
 HP.SuiteSkin:Attach(f,18)
 f:SetMovable(true);f:SetClampedToScreen(true);f:EnableMouse(true);f:RegisterForDrag('LeftButton');f:SetFrameStrata('MEDIUM')
 f.icon=f:CreateTexture(nil,'ARTWORK');f.icon:SetSize(32,32);f.icon:SetPoint('TOPLEFT',11,-17)
 f.label=UI.Text(f,'semibold',9,{1,.82,.33,1});f.label:SetPoint('TOPLEFT',54,-7);f.label:SetHeight(11)
 f.title=UI.Text(f,'semibold',12,{1,.97,.9,1});f.title:SetPoint('TOPLEFT',54,-21);f.title:SetHeight(15)
 f.detail=UI.Text(f,'regular',10,{.8,.79,.73,1});f.detail:SetPoint('TOPLEFT',54,-39);f.detail:SetHeight(12)
 for _,text in ipairs({f.label,f.title,f.detail})do text:SetJustifyH('LEFT');text:SetWordWrap(false)end
 f.time=UI.Text(f,'semibold',22,{1,.96,.81,1});f.time:SetPoint('TOPRIGHT',-11,-12);f.time:SetWidth(90);f.time:SetHeight(27);f.time:SetJustifyH('RIGHT')
 f.caption=UI.Text(f,'regular',9,{.82,.8,.72,1});f.caption:SetPoint('TOPRIGHT',-12,-40);f.caption:SetWidth(89);f.caption:SetHeight(11);f.caption:SetJustifyH('RIGHT')
 local rail=CreateFrame('StatusBar',nil,f);f.rail=rail
 rail:SetPoint('BOTTOMLEFT',54,7);rail:SetMinMaxValues(0,1)
 rail:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
 local bg=rail:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.18,.17,.14,.8)
 f.spark=rail:CreateTexture(nil,'OVERLAY');f.spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark');f.spark:SetBlendMode('ADD');f.spark:SetSize(10,15)
 f:SetScript('OnDragStart',function()
  if not B:Settings().locked then f:StartMoving();B.dragging=true end
 end)
 f:SetScript('OnDragStop',function()
  if not B.dragging then return end
  f:StopMovingOrSizing();B.dragging=nil
  local point,_,relative,x,y=f:GetPoint()
  if type(point)=='string'and type(relative)=='string'and type(x)=='number'and type(y)=='number'then
   D.char.travelBarPosition={point=point,relative=relative,x=x,y=y}
  end
 end)
 f:EnableMouseWheel(true)
 f:SetScript('OnMouseWheel',function(_,delta) local cfg=B:Settings();if not cfg.locked then cfg.scale=clamp(cfg.scale+delta*5,70,150,100);B:Update()end end)
 f:SetScript('OnMouseUp',function(_,button)
  if button=='RightButton'then Cfg:Open('travel')end
 end)
 f:SetScript('OnEnter',function()
  local m=B.model;if not m or not GameTooltip then return end
  GameTooltip:SetOwner(f,'ANCHOR_BOTTOM');GameTooltip:SetText(m.route)
  GameTooltip:AddLine(m.detail,.9,.85,.68,true);GameTooltip:AddLine(m.source,.7,.7,.7,true)
  GameTooltip:AddLine('Drag to move · Right-click for Travel settings',1,.82,.3,true);GameTooltip:Show()
 end)
 f:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
 self:Position()
end
function B:Position(reset)
 local f=self.frame;if not f then return end
 if reset then D.char.travelBarPosition=nil end
 local pos=D.char.travelBarPosition
 f:ClearAllPoints()
 if type(pos)=='table'and type(pos.x)=='number'and type(pos.y)=='number'then
  f:SetPoint(pos.point or 'CENTER',UIParent,pos.relative or 'CENTER',pos.x,pos.y)
 else f:SetPoint('CENTER',UIParent,'CENTER',0,140)end
end
function B:Update()
 if HP.Suite and not HP.Suite:On('travel') and not (self.previewUntil and GetTime()<self.previewUntil) then if self.frame then self.frame:Hide() end;return end
 if not D.db or not D.char then return end
 local cfg=self:Settings();local state=self:State()
 if not state then self.model=nil;if self.frame then self.frame:Hide()end;return end
 self:Create();local f=self.frame
 if not cfg.enabled and not(state and state.preview)then state=nil end
 local m=self:Model(state);self.model=m
 if not m then f:Hide();return end
 local width=clamp(cfg.width,280,480,360);local scale=clamp(cfg.scale,70,150,100)/100
 local minimal=cfg.style=='minimal'
 local signature=table.concat({width,scale,cfg.opacity,tostring(cfg.progress),cfg.style,UnitFactionGroup('player')or '',state.phase or '',tostring(UI.Theme.Current().id),UI.Theme.Opacity()},':')
 if self.layoutSignature~=signature then
  self.layoutSignature=signature
  f:SetSize(width,cfg.progress and 66 or 58);f:SetScale(scale)
  f.suiteConfig=cfg;HP.SuiteSkin:Apply(f,cfg)
  local red,green,blue=.75,.16,.12
  if UnitFactionGroup('player')~='Horde'then red,green,blue=.17,.43,.85 end
  if state.phase=='boarding'then red,green,blue=.2,.7,.36 elseif state.phase=='waiting'then red,green,blue=.88,.62,.13 end
  f.label:SetWidth(width-158);f.title:SetWidth(width-158);f.detail:SetWidth(width-158)
  f.rail:SetSize(width-66,minimal and 3 or 5);f.rail:SetStatusBarColor(red,green,blue,1)
 end
 f.suiteConfig=cfg;HP.SuiteSkin:Apply(f,cfg)
 f.label:SetText(m.label);f.title:SetText(m.title);f.detail:SetText(m.detail);f.time:SetText(m.clock);f.caption:SetText(m.caption)
 local icon=m.kind=='flight'and (UnitFactionGroup('player')=='Horde'and 'Ability_Mount_Wyvern_01'or 'Ability_Mount_Gryphon_01')or (m.kind=='zeppelin'and 'Ability_Mount_RocketMount'or 'INV_Misc_Map_01')
 if self.iconKey~=icon then
  self.iconKey=icon
  local ok,result=pcall(f.icon.SetTexture,f.icon,'Interface\\Icons\\'..icon)
  if not ok or result==false then f.icon:SetTexture('Interface\\Icons\\INV_Misc_Map_01')end
 end
 local railWidth=width-66
 f.rail:SetValue(m.progress or 0);f.rail:SetShown(cfg.progress)
 f.spark:ClearAllPoints();f.spark:SetPoint('CENTER',f.rail,'LEFT',railWidth*(m.progress or 0),0)
 f.spark:SetShown(cfg.progress and m.progress~=nil and m.progress>0 and m.progress<1)
 f:Show()
end
function B:Preview()
 self.previewUntil=GetTime()+30;self:Update()
end
local page=HP.nativeTravelPage;local build=page.build
page.build=function(canvas,width)
 local rows=build(canvas,width);local cfg=B:Settings()
 local extra={
  UI.HeaderRow(canvas,'Travel display',width),
  UI.CheckRow(canvas,Cfg,{label='Use selected guide skin and opacity',default=true,get=function()return cfg.followTheme~=false end,set=function(v)cfg.followTheme=v;B:Preview()end},width),
  UI.CheckRow(canvas,Cfg,{label='Flight master time previews',default=true,get=function()return cfg.flightPreview~=false end,set=function(v)cfg.flightPreview=v end},width),
  UI.ButtonRow(canvas,Cfg,{label='Preview and move the travel timer',desc='Drag anywhere on the timer. Right-click it to return here.',button='Preview',run=function()B:Preview()end},width),
  UI.SelectorRow(canvas,Cfg,{label='Timer style',default='classic',values={{'classic','Detailed'},{'minimal','Compact'}},get=function()return cfg.style end,set=function(v)cfg.style=v;B:Preview()end},width),
  UI.CheckRow(canvas,Cfg,{label='Show progress line',default=true,get=function()return cfg.progress end,set=function(v)cfg.progress=v;B:Preview()end},width),
  UI.CheckRow(canvas,Cfg,{label='Count elapsed time instead of remaining',default=false,get=function()return cfg.countup end,set=function(v)cfg.countup=v;B:Preview()end},width),
  UI.CheckRow(canvas,Cfg,{label='Lock travel timer position',default=false,get=function()return cfg.locked end,set=function(v)cfg.locked=v;B:Update()end},width),
  UI.SliderRow(canvas,Cfg,{label='Timer width',min=280,max=480,step=20,default=360,format=function(v)return tostring(v)end,get=function()return cfg.width end,set=function(v)cfg.width=v;B:Preview()end},width),
  UI.SliderRow(canvas,Cfg,{label='Timer scale',min=70,max=150,step=5,default=100,format=function(v)return v..' %'end,get=function()return cfg.scale end,set=function(v)cfg.scale=v;B:Preview()end},width),
  UI.SliderRow(canvas,Cfg,{label='Timer background opacity',min=20,max=100,step=5,default=88,format=function(v)return v..' %'end,get=function()return cfg.opacity end,set=function(v)cfg.opacity=v;B:Preview()end},width),
  UI.ButtonRow(canvas,Cfg,{label='Reset travel timer position',button='Reset',run=function()B:Create();B:Position(true);B:Preview()end},width)}
 for i=#extra,1,-1 do table.insert(rows,3,extra[i])end
 return rows
end
D:On('PLAYER_LOGIN',function()B:Update()end)
D:On('PLAYER_LOGOUT',function()if D.db then V:Tick()end end)
local driver=CreateFrame('Frame');B.driver=driver;local elapsed=0
-- Rendering updates only this small frame, never resizes/refreshes the quest guide.
driver:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;local active=B.frame and B.frame:IsShown()or B.previewUntil or V.flight or V.ride or HP.FlightInsights and HP.FlightInsights.hover
 local interval=active and .25 or 1
 if elapsed>=interval then elapsed=elapsed%interval;D:Safe(B.Update,B)end
end)

end)
