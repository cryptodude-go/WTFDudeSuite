local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'rares',function(...)
-- Native rare alert card, preview, settings and explicitly selected navigation detours.
local _,HP=...
local D=HP.Native;local R=HP.Rares
local UI,Cfg=D.UI,D.Config
local read=R.Read
local function method(obj,name,...)if obj and type(obj[name])=='function'then return pcall(obj[name],obj,...)end end
function R:Position(reset)
 local f=self.frame;if not f then return end;f:ClearAllPoints()
 local pos=not reset and D.char and D.char.rareAlertPosition
 if type(pos)=='table'and type(pos.x)=='number'and type(pos.y)=='number'then f:SetPoint(pos.point or 'BOTTOM',UIParent,pos.relative or 'BOTTOM',pos.x,pos.y)
 else f:SetPoint('BOTTOM',UIParent,'BOTTOM',0,150)end
 if reset and D.char then D.char.rareAlertPosition=nil end
end
local function button(parent,text,width,x,fn)
 local b=CreateFrame('Button',nil,parent);b:SetSize(width,25);b:SetPoint('BOTTOMLEFT',x,12)
 b.bg=UI.Shape(b,'row',UI.C.control,'BACKGROUND'):Place(b)
 b.edge=UI.Shape(b,'rowBorder',UI.C.border,'BORDER'):Place(b)
 b.text=UI.Text(b,'semibold',11,UI.C.text);b.text:SetPoint('CENTER');b.text:SetText(text);UI.Skin(b,function(self)UI.Color(self.text,UI.C.text)end)
 b:SetScript('OnClick',fn);return b
end
function R:Create()
 if self.frame then return end
 local f=CreateFrame('Frame','DudeDingRareAlert',UIParent,'BackdropTemplate');self.frame=f
 f:SetSize(430,184);f:SetFrameStrata('DIALOG');f:SetClampedToScreen(true);f:SetMovable(true);f:EnableMouse(true);f:RegisterForDrag('LeftButton')
 HP.SuiteSkin:Attach(f,30)
 f:SetScript('OnDragStart',function()if not R:DB().locked then f:StartMoving()end end)
 f:SetScript('OnDragStop',function()f:StopMovingOrSizing();local point,_,relative,x,y=f:GetPoint();D.char.rareAlertPosition={point=point,relative=relative,x=x,y=y}end)
 f.accent=f:CreateTexture(nil,'ARTWORK');f.accent:SetPoint('TOPLEFT',10,-30);f.accent:SetSize(410,1)
 f.brand=UI.Text(f,'regular',10,{1,.82,.25,1});f.brand:SetPoint('TOPLEFT',12,-12);f.brand:SetText("WTF! DUDE SUITE · Rares")
 f.category=UI.Text(f,'semibold',11,{1,.85,.35,1});f.category:SetPoint('TOPRIGHT',-34,-11)
 f.title=UI.Text(f,'semibold',17,{1,.93,.72,1});f.title:SetPoint('TOPLEFT',130,-43);f.title:SetWidth(284);f.title:SetHeight(42);f.title:SetJustifyH('LEFT')
 f.detail=UI.Text(f,'regular',11,{.78,.77,.7,1});f.detail:SetPoint('TOPLEFT',130,-90);f.detail:SetWidth(280);f.detail:SetHeight(42);f.detail:SetJustifyH('LEFT')
 f.count=UI.Text(f,'regular',10,{.75,.73,.65,1});f.count:SetPoint('BOTTOMRIGHT',-13,43)
 f.fallback=f:CreateTexture(nil,'ARTWORK');f.fallback:SetPoint('TOPLEFT',28,-54);f.fallback:SetSize(80,80)
 f.modelNote=UI.Text(f,'regular',9,{.68,.67,.6,1});f.modelNote:SetPoint('TOPLEFT',12,-135);f.modelNote:SetWidth(106);f.modelNote:SetJustifyH('CENTER')
 local ok,model=pcall(CreateFrame,'PlayerModel',nil,f)
 if ok then
  f.model=model;model:SetPoint('TOPLEFT',12,-35);model:SetSize(108,96);model:Hide()
  model:SetScript('OnModelLoaded',function()R:CheckModel(true)end)
  model:EnableMouseWheel(true);model:SetScript('OnMouseWheel',function(_,delta)R.zoom=math.max(.4,math.min(2.5,(R.zoom or 1)-delta*.1));method(model,'SetCamDistanceScale',R.zoom)end)
 end
 local dressed,dress=pcall(CreateFrame,'DressUpModel',nil,f)
 if dressed then f.dress=dress;dress:SetPoint('TOPLEFT',12,-35);dress:SetSize(108,96);dress:Hide()end
 f.go=button(f,'Waypoint',85,12,function()R:Track(R.current)end)
 f.dismiss=button(f,'Dismiss',72,103,function()R:Remove(R.current)end)
 f.ignore=button(f,'Ignore',66,181,function()R:IgnoreCurrent()end)
 f.prev=button(f,'<',28,307,function()R:Cycle(-1)end)
 f.next=button(f,'>',28,340,function()R:Cycle(1)end)
 local close=CreateFrame('Button',nil,f);close:SetSize(22,22);close:SetPoint('TOPRIGHT',-6,-5)
 close.text=UI.Text(close,'semibold',13,UI.C.secondary);close.text:SetPoint('CENTER');close.text:SetText('×');close:SetScript('OnClick',function()R:Remove(R.current)end)
 f:SetScript('OnEnter',function()
  local e=R.records[R.current];if not e or not GameTooltip then return end
  GameTooltip:SetOwner(f,'ANCHOR_TOP')
  if e.link then GameTooltip:SetHyperlink(e.link)else GameTooltip:AddLine(e.name);GameTooltip:AddLine(e.source or '',.8,.8,.7);if e.id then GameTooltip:AddLine('ID '..e.id,.7,.7,.7)end end
  GameTooltip:Show()
 end)
 f:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
 self:Position();f:Hide()
end
function R:CheckModel(loaded)
 local f=self.frame;local pending=self.modelPending
 if not f or not pending or self.current~=pending.key then return end
 local file=read(f.model and f.model.GetModelFileID,f.model)
 if loaded or type(file)=='number'and file>0 then
  f.model:Show();f.fallback:Hide();f.modelNote:SetText('3D model');self.modelPending=nil
  local e=self.records[self.current];local display=read(f.model.GetDisplayInfo,f.model)
  if e and e.kind=='npc'and not e.preview and e.id and type(display)=='number'and display>0 then self:DB().displays[e.id]=display end
 elseif self:Now()-pending.at>3 then
  f.model:Hide();f.fallback:Show();f.modelNote:SetText('Model unavailable');self.modelPending=nil
 end
end
function R:ShowModel(e,force)
 local f=self.frame;local cfg=self:DB();local cache=e.key..':'..tostring(cfg.models)
 if self.modelKey==cache and not force then return end
 self.modelKey=cache;self.modelPending=nil
 if f.model then method(f.model,'ClearModel');f.model:Hide()end
 if f.dress then method(f.dress,'ClearModel');f.dress:Hide()end
 f.fallback:SetTexture(e.icon or (e.kind=='treasure'and 'Interface\\Icons\\INV_Misc_TreasureChest01' or e.kind=='item'and 'Interface\\Icons\\INV_Misc_QuestionMark'or 'Interface\\Icons\\Ability_Creature_Cursed_02'))
 f.fallback:Show();f.modelNote:SetText(cfg.models and 'Icon preview'or '')
 if not cfg.models then return end
 if e.kind=='npc'and f.model then
  self.modelPending={key=e.key,at=self:Now()}
  local attempted=false
  if e.unit and read(UnitGUID,e.unit)==e.guid then local ok,result=method(f.model,'SetUnit',e.unit);attempted=ok and result~=false end
  if not attempted and e.id then
   local display=cfg.displays[e.id]
   if type(display)=='number'and display>0 then attempted=method(f.model,'SetDisplayInfo',display)end
   if not attempted then attempted=method(f.model,'SetCreature',e.id)end
  end
  if attempted then method(f.model,'SetPortraitZoom',.25);method(f.model,'SetFacing',.45);f.model:Show();f.modelNote:SetText('Loading model');self:CheckModel()
  else self.modelPending=nil;f.modelNote:SetText('Model unavailable')end
 elseif e.kind=='item'and e.link and type(e.equip)=='string'and e.equip~=''and f.dress then
  local unit=method(f.dress,'SetUnit','player')
  if unit and method(f.dress,'TryOn',e.link)then f.dress:Show();f.fallback:Hide();f.modelNote:SetText('Item on your character')end
 elseif e.kind=='item'and e.id and f.model then
  self.modelPending={key=e.key,at=self:Now()}
  if method(f.model,'SetItem',e.id)then f.model:Show();self:CheckModel()else self.modelPending=nil end
 end
end
function R:Render(force)
 if HP.Suite and not HP.Suite:On('rares') then if self.frame then self.frame:Hide() end;return end
 local cfg=self:DB();if not cfg then return end
 local e=self.records[self.current]
 if not cfg.enabled or not e then if self.frame then self.frame:Hide()end;return end
 self:Create();local f=self.frame
 f:SetScale(math.max(.7,math.min(1.5,cfg.scale/100)));f.suiteConfig=cfg;HP.SuiteSkin:Apply(f,cfg)
 local horde=read(UnitFactionGroup,'player')=='Horde'
 UI.Fill(f.accent,UI.C.line)
 local categories={npc='RARE NPC',treasure='TREASURE',event='EVENT',item='RARE LOOT'}
 f.category:SetText(e.preview and 'PREVIEW'or categories[e.kind]or 'RARE');f.title:SetText(e.name)
 local map=e.point and read(C_Map.GetMapInfo,e.point.map);local zone=map and self:Field(map,'name')
 f.detail:SetText((e.source or 'Rare sighting')..(zone and '\n'..zone or '')..(self.tracked==e.key and '\nWaypoint active'or ''))
 local index=1;for i,key in ipairs(self.order)do if key==self.current then index=i;break end end
 f.count:SetText(index..' / '..#self.order)
 f.go:SetEnabled(e.point~=nil and not e.preview);f.ignore:SetEnabled(not e.preview)
 self:ShowModel(e,force);f:Show()
end
function R:Cycle(direction)
 if #self.order==0 then return end
 local at=1;for i,key in ipairs(self.order)do if key==self.current then at=i;break end end
 self.current=self.order[((at-1+direction)%#self.order)+1];self:Render()
end
function R:Preview()
 local cfg=self:DB();local key='preview';self.records[key]={key=key,identity=key,kind='npc',name='Rare nearby · alert preview',source='Drag this window to move it',unit='player',guid=read(UnitGUID,'player'),preview=true,created=self:Now()}
 local found=false;for _,k in ipairs(self.order)do if k==key then found=true end end
 if not found then self.order[#self.order+1]=key end
 self.current=key
 local was=cfg.enabled;cfg.enabled=true;self:Render(true);cfg.enabled=was
 -- The preview is not a sighting and never changes the feature's enabled setting.
 self.previewUntil=self:Now()+20
end
function R:RefreshNavigation()
 local a=D.Arrow;a.point,a.shownPoint,a.farm,a.follow=nil,nil,nil,nil
 a:Update();if D.MinimapPins then D.MinimapPins:Update()end
 if HP.UpdateMapPins then HP.UpdateMapPins()end
end
function R:Track(key)
 local e=self.records[key];if not e or not e.point or e.preview then return end
 if self.tracked then self:Stop()end
 self.tracked=key;self.trackGuide=D.Engine.guide
 self.previousFocus=D.Arrow.forced
 D.Arrow:Focus({e.point},{action='dude-rare'})
 self.rareFocus=D.Arrow.forced;self:RefreshNavigation();self:Render()
end
function R:Stop()
 self.tracked=nil
 local a=D.Arrow
 if a.forced==self.rareFocus then
  local old=self.previousFocus
  a.forced=old and old.guide==D.Engine.guide and old.index==D.Engine.index and old or nil
 end
 self.previousFocus,self.rareFocus,self.trackGuide=nil,nil,nil
 HP.waypoint=nil
 self:RefreshNavigation()
end
function R:NavigationPoint()
 if HP.Suite and not HP.Suite:On('rares') then return end
 local cfg=self:DB();local e=self.records[self.tracked]
 if self.tracked and self.trackGuide~=D.Engine.guide then self.tracked,self.previousFocus,self.rareFocus=nil,nil,nil;return end
 if not cfg or not cfg.enabled or not e or not e.point or (HP.db and HP.db.paused)or D.Compat.IsGhost()then return end
 return e.point
end
-- A manual quest/service focus takes priority over an earlier rare detour.
local focus=D.Arrow.Focus
function D.Arrow:Focus(points,row)
 if R.tracked and not(row and row.action=='dude-rare')then R.tracked,R.previousFocus,R.rareFocus,R.trackGuide=nil,nil,nil,nil end
 return focus(self,points,row)
end
local unfocus=D.Arrow.Unfocus
function D.Arrow:Unfocus()
 if R.tracked then R.tracked,R.previousFocus,R.rareFocus,R.trackGuide=nil,nil,nil,nil end
 return unfocus(self)
end
local nearest=D.Engine.NearestPoint
function D.Engine:NearestPoint(points,prefer)
 local p=not points and R:NavigationPoint();if p then return nearest(self,{p},prefer)end
 return nearest(self,points,prefer)
end
local gather=HP.GetLiveGatherPoint
if gather then function HP.GetLiveGatherPoint(...)if R:NavigationPoint()then return end;return gather(...)end end
local arrow=D.Arrow.Update
function D.Arrow:Update()
 local p=R:NavigationPoint();if not p then return arrow(self)end
 local saved=D.Engine.candidates;D.Engine.candidates={p}
 local ok,err=pcall(arrow,self);D.Engine.candidates=saved
 if not ok then error(err)end
end
local arrival=D.Engine.OnPosition
function D.Engine:OnPosition(distance,point)
 if point and point.dudeRare then return end
 return arrival(self,distance,point)
end
local travel=D.Travel.Leg
function D.Travel:Leg(point)if point and point.dudeRare then self.leg=nil;return end;return travel(self,point)end
local trail=HP.TrailPoints
function HP.TrailPoints()
 if D.Arrow.manualPoint then return trail()end
 if D.Arrow.manualPoint then return trail()end
 local p=R:NavigationPoint();if not p then return trail()end
 local here=HP.GatherPosition();local dest={mapID=p.map,x=p.x/100,y=p.y/100};HP.waypoint=dest
 return here and {here,dest}or {dest}
end
function R:Apply()
 local cfg=self:DB();if not cfg then return end
 if not cfg.enabled or HP.Suite and not HP.Suite:On('rares') then
  if self.tracked then self:Stop()end
  self.records={};self.order={};self.pendingItems={};self.current=nil;self.modelKey=nil;self.status='Disabled'
 else
  local remove={};for key,e in pairs(self.records)do if not e.preview and not self:Allowed(e.kind)then remove[#remove+1]=key end end
  for _,key in ipairs(remove)do self:Remove(key)end
  self:Scan()
 end
 self:Render(true)
end
local function check(canvas,width,key,label,desc,default)
 return UI.CheckRow(canvas,Cfg,{label=label,desc=desc,default=default,get=function()return R:DB()[key]end,set=function(v)R:DB()[key]=v;R:Apply()end},width)
end
local tab={key='rares',label='Rares',pad=UI.SIZE.pad,gap=UI.SIZE.gap}
tab.build=function(canvas,width)
 local cfg=R:DB()
 return {
 UI.HeaderRow(canvas,'Rare discoveries',width),
 check(canvas,width,'followTheme','Use selected guide skin and opacity','Shares the current guide theme, colors and transparency.',true),
 check(canvas,width,'enabled','Enable rare scanner','Nearby sightings from the game, visible nameplates and target/mouseover. No separate addon required.',false),
 check(canvas,width,'npcs','Rare NPCs and rare elites',nil,true),
 check(canvas,width,'treasures','Nearby treasures and containers','Only treasure sightings reported by the game; ordinary herbs/ore stay in Gathering.',true),
 check(canvas,width,'events','Nearby vignette events',nil,false),
 check(canvas,width,'items','Rare / epic items looted by me','Optional loot notification with item tooltip and wearable preview when supported.',false),
 check(canvas,width,'models','Show 3D model','NPC model or wearable item on your character; icon fallback for unavailable models and treasures.',true),
 check(canvas,width,'sound','Play alert sound','Repeated sightings are suppressed; sound alerts are rate-limited.',true),
 UI.SelectorRow(canvas,Cfg,{label='Alert sound',default=8959,values={{8959,'Rare discovery'},{3175,'Scout ping'},{618,'Quest chime'}},get=function()return cfg.soundID end,set=function(v)cfg.soundID=v;read(PlaySound,v,'Master')end},width),
 check(canvas,width,'combat','Detect during combat','Uses only readable game data. Hidden identities are never guessed.',true),
 check(canvas,width,'locked','Lock alert position',nil,false),
 UI.SliderRow(canvas,Cfg,{label='Alert scale',min=70,max=150,step=5,default=100,get=function()return cfg.scale end,set=function(v)cfg.scale=v;R:Preview()end,format=function(v)return v..' %'end},width),
 UI.SliderRow(canvas,Cfg,{label='Background opacity',min=30,max=100,step=5,default=92,get=function()return cfg.opacity end,set=function(v)cfg.opacity=v;R:Preview()end,format=function(v)return v..' %'end},width),
 UI.SelectorRow(canvas,Cfg,{label='Alert stays visible',default=45,values={{20,'20 seconds'},{45,'45 seconds'},{90,'90 seconds'}},get=function()return cfg.duration end,set=function(v)cfg.duration=v end},width),
 UI.ButtonRow(canvas,Cfg,{label='Preview 3D alert and move window',button='Preview',run=function()R:Preview()end},width),
 UI.ButtonRow(canvas,Cfg,{label='Stop rare waypoint',desc='Return to your quest / gathering route.',button='Stop',run=function()R:Stop();R:Render()end},width),
 UI.ButtonRow(canvas,Cfg,{label='Reset ignored rares / treasures',button='Reset',run=function()cfg.ignore={};R.seen={};R:Scan()end},width),
 UI.ButtonRow(canvas,Cfg,{label='Reset alert position',button='Reset',run=function()R:Create();R:Position(true);R:Preview()end},width),
 UI.InfoRow(canvas,'A waypoint starts only when you click Waypoint. Detection does not change your quest step. No full RareScanner loot/spawn/respawn database is bundled.',width)}
end
Cfg.TABS[#Cfg.TABS+1]=tab;Cfg.TAB.rares=#Cfg.TABS
local originalTick=R.Tick
function R:Tick()
 originalTick(self)
 if self.previewUntil and self:Now()>self.previewUntil then self.previewUntil=nil;self:Remove('preview')end
end
D:On('PLAYER_LOGIN',function()R:Apply()end)
local slash=SlashCmdList.DUDEWHERESMYDING
SlashCmdList.DUDEWHERESMYDING=function(input)
 local args=(input or ''):lower():match('^%s*rares%s*(.-)%s*$')
 if args~=nil then
  if args=='on'or args=='off'then R:DB().enabled=args=='on';R:Apply()
  elseif args=='preview'then R:Preview()
  elseif args=='stop'then R:Stop()
  else Cfg:Open('rares')end
  return
 end
 return slash(input)
end

end)
