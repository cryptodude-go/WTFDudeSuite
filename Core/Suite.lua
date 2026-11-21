local _,_WTF=...
_WTF.Defer(20,'Core/Suite.lua',function(...)
-- Modular suite settings. Internal save/folder names intentionally remain compatible.
local _,HP=...
local D=HP.Native
local C,UI=D.Config,D.UI
for _,key in ipairs({'spam','rares'})do
 if not C.TAB[key]then C.TABS[#C.TABS+1]={key=key,label=key,build=function()return {}end,pad=UI.SIZE.pad,gap=UI.SIZE.gap};C.TAB[key]=#C.TABS end
end
local S={version=D.version~='dev'and D.version or '1.9.1'};HP.Suite=S
D.TITLE='WTF! DUDE SUITE'
local function native(key)
 if key=='marking' then return HP.GroupMarks:DB() end
 if key=='spam' then return HP.SpamFilter:DB() end
 if key=='rares' then return HP.Rares:DB() end
 if key=='travel' and D.db then
  D.db.ui.travelClock=D.db.ui.travelClock or {enabled=true,docks=true}
  return D.db.ui.travelClock
 end
end
function S:DB()
 if not D.db then return end
 D.db.suite=D.db.suite or {enabled=true,modules={}}
 local db=D.db.suite
 if db.enabled==nil then db.enabled=true end
 db.modules=db.modules or {};return db
end
function S:Enabled(key)
 local db=self:DB();if not db then return true end
 if key=='suite' then return db.enabled end
 if not HP.ModuleAvailable(key)then return false end
 local cfg=native(key)
 if cfg then return cfg.enabled~=false end
 return db.modules[key]~=false
end
function S:On(key)
 local db=self:DB();if not db then return true end
 if not db.enabled then return false end
 if key=='book' then
  key=HP.db and HP.db.guideBook or 'leveling'
  if key=='professions' and (HP.db.professionGuide=='Mining' or HP.db.professionGuide=='Herbalism' or HP.db.professionGuide=='Fishing') then key='gathering' end
 end
 return self:Enabled(key)
end
function S:ProfessionAllowed(name)
 if name=='Mining' or name=='Herbalism' or name=='Fishing' then return self:On('gathering') end
 return self:On('professions')
end
function S:DetourActive()
 return HP.Rares:NavigationPoint()~=nil or HP.GetLiveGatherPoint()~=nil
end
function S:CanNavigate()
 return self:On('navigation') and (self:On('book') or D.Arrow.manualPoint ~= nil or self:DetourActive())
end
local function hide(f)if f and f.Hide then f:Hide() end end
function S:Refresh()
 if not D.db or not HP.db or not HP.nativeStarted then return end
 if not self:On('gathering') then
  local g=HP.liveGathering;g.target=nil;g.scan=nil;g.nodes={};g.status='Disabled in Suite settings'
  hide(HP.gatherNodeMini);hide(HP.gatherOverlay)
 end
 if not self:On('navigation') then D.Arrow.manualPoint=nil;D.Arrow:MarkWorld(nil);HP.QuestPins:HidePins();hide(D.Arrow.frame);if D.TaxiMap then D.TaxiMap:Hide()end end
 if HP.Sparkles.ApplySuite then HP.Sparkles.ApplySuite() end
 HP.GroupMarks:Apply();HP.SpamFilter:Changed();HP.Rares:Apply()
 if not self:On('travel') then HP.TravelDisplay.previewUntil=nil end
 if not self:On('automation') then
  if D.GearHint then D.GearHint:Hide()end
  if D.RewardHint then D.RewardHint:Hide()end
 end
 HP.Refresh();HP.TravelDisplay:Update()
 C:RefreshRows()
end
function S:Set(key,on)
 local db=self:DB();if not db then return end
 on=on==true
 if key=='suite' then db.enabled=on
 else
  local cfg=native(key)
  if cfg then cfg.enabled=on else db.modules[key]=on end
 end
 self:Refresh()
end
local descriptions={
 suite='Enable the suite. Individual module choices and character progress are kept.',
 leveling='Quest guides, current objectives and automatic step progress.',
 automation='Quest acceptance, turn-ins, merchant actions and equipment suggestions.',
 navigation='Waypoint arrow, quest map pins and minimap route lines.',
 professions='Crafting and skill-based profession guides, including steps while leveling.',
 reputation='Reputation guide steps for the faction you choose.',
 gathering='Herb and ore circuits, fishing pool circles and gathering history.',
 sparkles='Quest loot, herbs, ore, quest objects and nearby lootable corpses.',
 marking='Group mark planning and the click / key controls for party and raid.',
 spam='Chat filtering, custom rules and automatic ignore. Existing WoW ignores remain until removed.',
 rares='Rare NPC, treasure and optional rare loot alerts with model previews.',
 travel='Flight, boat and zeppelin timers. Your learned travel times are kept.',
 community='Party / raid announcements and optional character activity statistics.',
}
S.descriptions=descriptions
local function master(canvas,width,key,label)
 return UI.CheckRow(canvas,C,{label='Enable '..label,desc=descriptions[key],default=key~='rares' and key~='marking',
 get=function()return S:Enabled(key)end,set=function(v)S:Set(key,v)end},width)
end
local function pageRow(canvas,width,label,def)
 return UI.PageRow(canvas,C,{label=label,open=function()C:OpenPage(def)end},width)
end
local function subpage(index,title)
 local tab=C.TABS[index];return {key='suite-'..tab.key,title=title,build=tab.build,signature=tab.signature}
end
local routePage=subpage(C.TAB.route,'Leveling route preferences')
local bindingPage=subpage(C.TAB.bindings,'Keybindings')
C.TABS[C.TAB.route].suiteHidden=true;C.TABS[C.TAB.bindings].suiteHidden=true
-- Common options stay in their original builders and keep the original saved keys.
local function attach(index,key,label,extras)
 local tab=C.TABS[index];local build=tab.build;tab.label=label;tab.module=key
 tab.build=function(canvas,width)
  local rows={master(canvas,width,key,label)}

  for _,row in ipairs(build(canvas,width))do
   local name=row.opts and row.opts.label
   if name~='Enable rare scanner' and name~='Enable Spam Filter' and name~='Enable group mark assistant' and name~='Show travel timers' then
    rows[#rows+1]=row
   else row:Hide() end
  end
  if extras then extras(rows,canvas,width)end
  return rows
 end
end
attach(C.TAB.guide,'leveling','Leveling',function(rows,canvas,width)
 rows[#rows+1]=UI.ButtonRow(canvas,C,{label='Use leveling guide',button='Open',run=function()HP.ChooseGuideBook('leveling')end},width)
 rows[#rows+1]=pageRow(canvas,width,'Route preferences',routePage)
end)
attach(C.TAB.automation,'automation','Automation')
attach(C.TAB.arrow,'navigation','Arrow & maps',function(rows,canvas,width)
 local function check(label,key,inverted)
  rows[#rows+1]=UI.CheckRow(canvas,C,{label=label,get=function()if inverted then return not HP.db[key] end;return HP.db[key]==true end,
  set=function(v)if inverted then HP.db[key]=not v else HP.db[key]=v end;HP.UpdateRouteLines()end},width)
 end
 check('Show route lines','hideRouteLines',true)
 check('Show minimap route lines','hideMinimapTrail',true)
 check('Static route lines','staticRouteTrail',false)
end)
attach(C.TAB.appearance,'suite','Suite options',function(rows,canvas,width)
 rows[#rows+1]=pageRow(canvas,width,'Keybindings',bindingPage)
 rows[#rows+1]=UI.InfoRow(canvas,'WTF! DUDE SUITE · Version '..S.version..'\nDrag the title bar to move Settings. Saved progress and module preferences are preserved.',width)
end)
attach(C.TAB.gathering,'gathering','Gathering',function(rows,canvas,width)
 -- Reuse the original gathering controls, without profession/reputation/chat controls.
 local extra=HP.nativeExtrasPage.build(canvas,width)
 local keep=false
 for _,row in ipairs(extra)do
  if row.header and row.label and row.label:GetText()=='Gathering routes' then keep=true end
  if row.header and row.label and row.label:GetText()=='Minimap route lines' then keep=false end
  if keep then rows[#rows+1]=row else row:Hide() end
 end
end)
attach(C.TAB.spam,'spam','Ignore & spam')
attach(C.TAB.rares,'rares','Rare scanner')
local function add(key,label,build)
 local tab={key=key,label=label,build=build,pad=UI.SIZE.pad,gap=UI.SIZE.gap}
 C.TABS[#C.TABS+1]=tab;C.TAB[key]=#C.TABS
 attach(#C.TABS,key,label)
end
local function choices(books)
 local list={};for id,b in pairs(books)do list[#list+1]={value=id,text=b.name or tostring(id)}end
 table.sort(list,function(a,b)return a.text<b.text end);return list
end
add('professions','Professions',function(canvas,width)
 return {
 UI.HeaderRow(canvas,'Profession guide',width),
 UI.DropdownRow(canvas,C,{label='Profession',items=function()return choices(HP.professionBooks)end,get=function()return HP.db.professionGuide end,
 set=function(v)HP.db.professionGuide=v;HP.Refresh()end},width),
 UI.CheckRow(canvas,C,{label='Include professions while leveling',get=function()return HP.db.includeProfessionsWhileLeveling==true end,
 set=function(v)HP.db.includeProfessionsWhileLeveling=v;HP.Refresh()end},width),
 UI.ButtonRow(canvas,C,{label='Show only profession steps',button='Open guide',run=function()HP.ChooseGuideBook('professions')end},width),
 UI.InfoRow(canvas,'Herbalism and Mining node circles and circuits have their own Gathering tab.',width)}
end)
add('reputation','Reputation',function(canvas,width)
 return {UI.HeaderRow(canvas,'Reputation guide',width),
 UI.DropdownRow(canvas,C,{label='Reputation',items=function()return choices(HP.reputationBooks)end,get=function()return HP.db.reputationGuide end,
 set=function(v)HP.db.reputationGuide=v;HP.Refresh()end},width),
 UI.ButtonRow(canvas,C,{label='Show reputation steps',button='Open guide',run=function()HP.ChooseGuideBook('reputation')end},width)}
end)
add('sparkles','Sparkles',HP.nativeSparklesPage.build)
add('marking','Group marks',HP.nativeGroupMarksPage.build)
add('travel','Travel timers',HP.nativeTravelPage.build)
add('community','Chat & statistics',HP.nativeCommunityPage.build)
C.RAIL_ORDER={}
for _,key in ipairs({'appearance','guide','professions','reputation','gathering','arrow','automation','sparkles','marking','spam','rares','travel','community'})do
 local index=C.TAB[key];local tab=C.TABS[index]
 if tab.module=='suite'or HP.ModuleAvailable(tab.module)then C.RAIL_ORDER[#C.RAIL_ORDER+1]=index else tab.suiteHidden=true end
end
local function stopArrow(self)
 self:MarkWorld(nil);HP.QuestPins:HidePins();hide(self.frame)
end
local arrowUpdate,arrowTick=D.Arrow.Update,D.Arrow.Tick
function D.Arrow:Update(...)
 if not S:CanNavigate() then stopArrow(self);return end
 return arrowUpdate(self,...)
end
function D.Arrow:Tick(...)
 if not S:CanNavigate() then stopArrow(self);return end
 return arrowTick(self,...)
end
-- Guide progress stops while its module is disabled, even when an event was queued.
local refresh=D.Engine.Refresh
function D.Engine:Refresh(...)
 if not S:On('book') then D.Panel:Update();return end
 return refresh(self,...)
end
local pins=D.MinimapPins.Update
function D.MinimapPins:Update(...)
 if not S:On('navigation') then HP.QuestPins:HidePins();return end
 return pins(self,...)
end
-- Keep the hidden subpages reachable from existing shortcuts and controller navigation.
local open=C.Open
function C:Open(tab,...)
 local index=(type(tab)=='string'and self.TAB[tab]or tab)or self.tab or self.TAB.appearance
 if index==self.TAB.route and not HP.ModuleAvailable('leveling')then index=self.TAB.appearance;tab='appearance'end
 if index and self.TABS[index]and self.TABS[index].suiteHidden and index~=self.TAB.route and index~=self.TAB.bindings then index=self.TAB.appearance;tab='appearance'end
 if index==self.TAB.route then open(self,'guide',...);if self.frame and self.frame:IsShown() then self:OpenPage(routePage)end;return end
 if index==self.TAB.bindings then open(self,'appearance',...);if self.frame and self.frame:IsShown() then self:OpenPage(bindingPage)end;return end
 return open(self,index,...)
end
local legacy=SlashCmdList.DUDEWHERESMYDING
local function command(input)
 local key=(input or ''):lower():match('^%s*(.-)%s*$')
 local aliases={settings='appearance',options='appearance',leveling='guide',profession='professions',gather='gathering',ignore='spam',marks='marking',rare='rares'}
 key=aliases[key] or key
 if key=='' then C:Open('appearance')elseif C.TAB[key] then C:Open(key)else legacy(input)end
end
SlashCmdList.WTFDUDESUITE=command
SLASH_WTFDUDESUITE1='/wtf';SLASH_WTFDUDESUITE2='/dudesuite'
local panelUpdate=D.Panel.Update
function D.Panel:Update(...)
 local result=panelUpdate(self,...)
 if not S:On('book')and self.frame then self.frame:Hide()end
 return result
end
D:On('PLAYER_LOGIN',function()S:DB();S:Refresh()end)

end)
