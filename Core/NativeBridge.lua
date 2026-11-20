-- Full Ding v1.8.1 runtime plus Dude's profession, reputation and gathering tools.
-- The original runtime stays isolated from both the legacy progress DB and another Ding addon.
local _,HP=...
local D=HP.Native
local UI,Cfg,E,P=D.UI,D.Config,D.Engine,D.Panel
local function ready() return D.db and HP.db and HP.nativeStarted end
local function auxiliary() return ready() and HP.db.guideBook~='leveling' end
local function hideLegacy()
 for _,f in pairs({HP.frame,HP.arrow,HP.minimapButton,HP.settings,HP.npcPreview,HP.itemFrame,HP.questItemBar}) do if f and f.Hide and f:IsShown() then f:Hide() end end
 if HP.frame and not HP.Call(InCombatLockdown) then
  for _,b in pairs({HP.frame.actionTarget,HP.frame.actionUse,HP.frame.setWaypoint,HP.frame.skipStep}) do if b:IsShown() then b:Hide() end end
  for _,b in ipairs(HP.questItemBar and HP.questItemBar.inlineButtons or {}) do if b:IsShown() then b:Hide() end end
 end
end
local function task()
 if not HP.db then return end
 if HP.db.guideBook=='professions' then return HP.ProfessionTask(HP.db.professionGuide or 'Herbalism') end
 if HP.db.guideBook=='reputation' then return HP.ReputationTask(HP.db.reputationGuide or 529) end
end
local function refreshTask()
 local t=task();HP.auxTask=t;HP.auxiliaryActive=t~=nil
 HP.auxTitle=t and t.book.name;HP.auxProgress=t and t.percent or 0
 HP.waypoint=t and not HP.db.paused and not HP.db.hidden and HP.db.autoWaypoint~=false and (HP.manualWaypoint or t.location) or nil
 if auxiliary() then local p=HP.waypoint;E.candidates=p and {{map=p.mapID,x=p.x*100,y=p.y*100,label=HP.auxTitle}} or {};D.Travel.leg=nil;D.Arrow.farm=nil end
 if t and t.gatherRoute then HP.activeGatherRoute=t.gatherRoute.key;HP.gatherMap=t.gatherRoute.mapID;HP.gatherPoint=1 end
 return t
end
local oldRefresh=HP.Refresh
function HP.Refresh(...)
 if not ready() then return oldRefresh(...) end
 if auxiliary() then refreshTask() end
 if D.Arrow.frame then D.Arrow:Update() end
 P:Update();HP.UpdateRouteLines();HP.UpdateGatherWorldNodes();HP.DrawGatherMinimap();hideLegacy()
end
local oldArrow=HP.UpdateArrow
function HP.UpdateArrow(...) if ready() then if HP.arrow then HP.arrow:Hide() end;return end;return oldArrow(...) end
for _,name in ipairs({'OnQuestList','OnDetail','OnProgress','OnComplete'}) do local method=D.AutoQuest[name];D.AutoQuest[name]=function(self,...)if ready() and (HP.db.paused or auxiliary()) then return end;return method(self,...)end end
local oldAssist=HP.HandleQuestAssistance
function HP.HandleQuestAssistance(...) if ready() then return end;return oldAssist(...) end
local oldItems=HP.UpdateQuestItemBar
function HP.UpdateQuestItemBar(...) if ready() then hideLegacy();return end;return oldItems(...) end
local oldUse=HP.UseGuide
function HP.UseGuide(...) if ready() then return HP.Refresh() end;return oldUse(...) end
local oldSettings=HP.ToggleSettings
function HP.ToggleSettings(...) if ready() then return Cfg:Toggle() end;if oldSettings then return oldSettings(...) end end
local oldMove=HP.Move
function HP.Move(delta)
 if not ready() then return oldMove(delta) end
 if auxiliary() then if HP.db.guideBook=='professions' then HP.MoveGatherStep(delta) end;return HP.Refresh() end
 if delta<0 then E:Prev() else E:Next() end
end
local oldChoose=HP.ChooseGuideBook
function HP.ChooseGuideBook(kind)
 if not ready() then return oldChoose(kind) end
 if kind~='leveling' and kind~='professions' and kind~='reputation' then return end
 if HP.Call(InCombatLockdown) then HP.pendingGuideBook=kind;return end
 HP.db.guideBook=kind;HP.manualWaypoint=nil;D.Arrow.forced=nil;D.Arrow.point=nil;P.holding=nil
 if kind=='leveling' then HP.auxiliaryActive=false;HP.auxTask=nil;E:Refresh() else HP.Refresh() end
end
local oldPlate=HP.RefreshPlate
function HP.RefreshPlate(unit) if ready() then if HP.plates and HP.plates[unit] then HP.plates[unit]:Hide() end;return end;return oldPlate(unit) end
-- Suppress duplicate quest acceptance/rewards from the legacy interface.
local legacyEvent=HP.mainEvents:GetScript('OnEvent')
HP.mainEvents:SetScript('OnEvent',function(self,event,...)
 if event=='PLAYER_LOGIN' and D.db then HP.DetectCharacter();if not HP.frame then HP.CreateUI() end;return end
 if ready() then
  if event=='PLAYER_LEVEL_UP' then local level=...;HP.RecordXP(level);HP.DetectCharacter() elseif event=='PLAYER_XP_UPDATE' then HP.RecordXP() end
  if event=='QUEST_ACCEPTED' then local _,id=...;if type(id)=='number' and HP.questAnnounced then HP.questAnnounced[id]=nil end end
  if event=='QUEST_LOG_UPDATE' or event=='QUEST_ACCEPTED' or event=='QUEST_TURNED_IN' then HP.CheckQuestAnnouncements(false) end
  if event=='QUEST_TURNED_IN' then local q=...;if type(q)=='number' then HP.db.completed[q]=true end end
  if event=='QUEST_DETAIL' or event=='QUEST_PROGRESS' or event=='QUEST_COMPLETE' then HP.RecordQuestLocation(event);return end
  if event=='PLAYER_REGEN_ENABLED' and HP.pendingGuideBook then local k=HP.pendingGuideBook;HP.pendingGuideBook=nil;HP.ChooseGuideBook(k) end
  if auxiliary() then HP.Refresh() end
  return
 end
 return legacyEvent(self,event,...)
end)
-- Native tracker rows are also used for our two live skill/standing books.
local nativeRows=P.Rows
function P:Rows(content)
 if auxiliary() then
  local t=HP.auxTask or refreshTask();local rows={}
  if not t then return {{state='impossible',kind='other',text='Choose a profession or reputation in Settings.'}} end
  for _,r in ipairs(t.rows or {}) do rows[#rows+1]={state='todo',kind=r.kind=='travel' and 'go' or 'other',text=r.text,dudeRow=r,point=t.location} end
  return rows
 end
 local rows=nativeRows(self,content)
 if ready() and HP.db.includeProfessionsWhileLeveling then
  local t=HP.ProfessionTask(HP.db.professionGuide or 'Herbalism')
  if t and not t.complete and t.rows[1] then rows[#rows+1]={state='extra',kind='other',text=t.book.name..': '..t.rows[1].text,dudeRow=t.rows[1],point=t.location} end
 end
 return rows
end
local nativeCheckHold=P.CheckHold
function P:CheckHold() if auxiliary() then self.holding=nil;return end;return nativeCheckHold(self) end
local nativeUpdate=P.Update
function P:Update()
 nativeUpdate(self)
 if not auxiliary() or not self.frame then return end
 local f,t=self.frame,HP.auxTask
 if not t then return end
 f.title:SetText(UI.Colored('accent',D.TRACKER_TITLE or D.TITLE)..' · '..t.book.name)
 local now=t.rank or (t.state and t.state.value) or 0
 local total=t.rank and 300 or (t.state and t.state.high) or 1
 f.stepText:SetText(t.rank and ('Skill '..now) or 'Reputation')
 f.stepTotal:SetText(t.rank and ' / 300' or (' '..math.floor((t.percent or 0)*100)..'%'))
 f.prev:SetEnabled(t.gatherRoute~=nil);f.next:SetEnabled(t.gatherRoute~=nil)
 f.fillHolder:SetWidth(math.max(4,((D.db.panel.width or 300)-16)*(t.percent or 0)));f.fillHolder:SetShown((t.percent or 0)>0)
 if f.mini and f.mini.lineFill then f.mini.lineFill:SetWidth(math.max(1,((D.db.panel.width or 300)-6)*(t.percent or 0))) end
end
local showQuest=P.ShowQuest
function P:ShowQuest(row,owner)
 if row and row.dudeRow then
  local r=row.dudeRow
  GameTooltip:SetOwner(owner,'ANCHOR_RIGHT');GameTooltip:SetText(UI.StripColors(r.text or ''))
  if r.recipeGuide and HP.ShowProfessionRecipeTooltip then HP.ShowProfessionRecipeTooltip(owner,r.recipeGuide);return end
  if r.tooltipText then GameTooltip:AddLine(r.tooltipText,1,.9,.65,true) end
  GameTooltip:Show();return
 end
 return showQuest(self,row,owner)
end
local aim=P.Aim
function P:Aim(row)
 if row and row.dudeRow and row.point then HP.manualWaypoint=row.point;HP.Refresh();return end
 return aim(self,row)
end
local engineUpdate=E.Update
function E:Update() if auxiliary() or ready() and HP.db.paused then HP.Refresh();return end;return engineUpdate(self) end
local nextStep,prevStep,skipStep=E.Next,E.Prev,E.Skip
function E:Next() if auxiliary() then HP.Move(1);return end;return nextStep(self) end
function E:Prev() if auxiliary() then HP.Move(-1);return end;return prevStep(self) end
function E:Skip() if auxiliary() then HP.Move(1);return end;return skipStep(self) end
local setPack=E.SetPack
function E:SetPack(id) if ready() then HP.db.guideBook='leveling';HP.auxiliaryActive=false end;return setPack(self,id) end
local setGuide=E.SetGuide
function E:SetGuide(...) if ready() then HP.db.guideBook='leveling';HP.auxiliaryActive=false end;return setGuide(self,...) end
local wantedItem=D.ItemButton.Wanted
function D.ItemButton:Wanted()if auxiliary() then return end;return wantedItem(self) end
local onPosition=E.OnPosition
function E:OnPosition(distance,point) if auxiliary() or point and point.dudeFallback then return end;return onPosition(self,distance,point) end
local nearest=E.NearestPoint
function E:NearestPoint(points,prefer)
 if auxiliary() and not points then
  local p=HP.waypoint
  if not p then return end
  return nearest(self,{{map=p.mapID,x=p.x*100,y=p.y*100,label=HP.auxTitle or 'Guide'}},prefer)
 end
 if not points and not (self.candidates and #self.candidates>0) and HP.NativeFallbackPoints then
  local fallback=D.Arrow.fallbackActive and D.Arrow.fallbackPoints or HP.NativeFallbackPoints()
  return nearest(self,fallback,prefer)
 end
 return nearest(self,points,prefer)
end
local leg=D.Travel.Leg
function D.Travel:Leg(point) if auxiliary() then return end;return leg(self,point) end
-- Inventory/local-only instructions have no destination of their own. Continue
-- guiding nearby unfinished objectives, without completing the local instruction.
function HP.NativeFallbackPoints()
 local points={}
 local function add(list) for _,p in ipairs(list or {}) do if type(p.map)=='number' and type(p.x)=='number' and type(p.y)=='number' then local copy={};for k,v in pairs(p) do copy[k]=v end;copy.dudeFallback=true;points[#points+1]=copy end end end
 if E.finished then return points end
 for _,entry in ipairs(D.Along and D.Along.shown or {}) do add(entry.points) end
 if #points>0 then return points end
 for _,step in ipairs(E:NextSteps(8)) do
  for i=E.index+1,#(E.guide and E.guide.steps or {}) do
   if E.guide.steps[i]==step then add(E:Candidates(step,i));break end
  end
  if #points>0 then break end
 end
 return points
end
local arrowUpdate=D.Arrow.Update
function D.Arrow:Update()
 if HP.db and HP.db.paused and not self.manualPoint then if self.frame then UI.FadeOut(self.frame,.2) end;return end
 if auxiliary() and not self.manualPoint then
  self.point=nil;self.forced=nil;self.otherContinent=nil
  self:Tick()
  if HP.waypoint and D.db.arrow.shown and P:Visible() then UI.FadeIn(self.frame,.2) else UI.FadeOut(self.frame,.2) end
  return
 end
 local candidates=E.candidates
 self.fallbackActive=not self.manualPoint and not (candidates and #candidates>0) and not self.forced and not (D.Finder and D.Finder.trip)
 if self.fallbackActive then self.fallbackPoints=HP.NativeFallbackPoints();E.candidates=self.fallbackPoints else self.fallbackPoints=nil end
 local result=arrowUpdate(self)
 if self.fallbackActive then E.candidates=candidates end
 return result
end
-- Feed our animated minimap/map trail from the native arrow's actual travel leg.
local oldTrail=HP.TrailPoints
function HP.TrailPoints()
 if not ready() or auxiliary() and not D.Arrow.manualPoint then return oldTrail() end
 local p=D.Arrow.shownPoint or D.Arrow.point
 HP.waypoint=p and {mapID=p.map,x=p.x/100,y=p.y/100} or nil
 local points={};local map=HP.GatherCurrentMap();local here=map and HP.GatherPosition(map)
 if here then points[1]=here end
 if HP.waypoint then points[#points+1]=HP.waypoint end
 return points
end
local routeUpdate=HP.UpdateRouteLines
function HP.UpdateRouteLines()
 if ready() then
  HP.db.hidden=not D.db.panel.shown
  if not auxiliary() or D.Arrow.manualPoint then HP.TrailPoints() end
 end
 return routeUpdate()
end
-- Native settings widgets, including exactly the original yellow square checkmarks.
local function check(canvas,width,label,key,desc,default)
 return UI.CheckRow(canvas,Cfg,{label=label,desc=desc,get=function() if HP.db[key]==nil then return default==true end;return HP.db[key]==true end,
 set=function(v) HP.db[key]=v;HP.Refresh() end},width)
end
local function drop(canvas,width,label,items,key,after)
 return UI.DropdownRow(canvas,Cfg,{label=label,items=function()local list=type(items)=='function' and items() or items;for _,v in ipairs(list) do v.text=v.text or v.label end;return list end,get=function()local v=HP.db[key];if v==nil and (key=='gatherZone' or key=='gatherResource') then return 'auto' end;return v end,set=function(v) if after==HP.ChooseGuideBook then after(v);return end;HP.db[key]=v;if after then after(v) else HP.Refresh() end end},width)
end
local function editMessage(key,title)
 local f=HP.nativeMessageEditor
 if not f then
  f=CreateFrame('Frame',nil,UIParent);f:SetSize(500,140);f:SetPoint('CENTER');f:SetFrameStrata('DIALOG');f:EnableMouse(true);UI.Window(f,'dialog')
  f.title=UI.Text(f,'semibold',14,UI.C.text);f.title:SetPoint('TOPLEFT',16,-15)
  f.edit=CreateFrame('EditBox',nil,f,'InputBoxTemplate');f.edit:SetSize(460,30);f.edit:SetPoint('TOPLEFT',20,-46);f.edit:SetAutoFocus(false);f.edit:SetMaxLetters(220)
  local hint=UI.Text(f,'regular',11,UI.C.secondary);hint:SetPoint('TOPLEFT',16,-92);hint:SetText('Enter: save   ·   Escape: cancel   ·   {quest} {level} {time} {player}')
  f.edit:SetScript('OnEnterPressed',function(self)HP.db[f.key]=self:GetText();self:ClearFocus();f:Hide();Cfg:RefreshRows()end)
  f.edit:SetScript('OnEscapePressed',function(self)self:ClearFocus();f:Hide()end)
  HP.nativeMessageEditor=f
 end
 f.key=key;f.title:SetText(title);f.edit:SetText(HP.db[key] or '');f:Show();f.edit:SetFocus();f.edit:HighlightText()
end
local community={key='dude-community',title='Announcements and statistics'}
function community.build(canvas,width)
 local rows={UI.HeaderRow(canvas,'Chat announcements',width)}
 for _,v in ipairs({{'Quest objectives complete: party','announceQuestParty'},{'Quest objectives complete: raid','announceQuestRaid'},{'Level gained: party','announceLevelParty'},{'Level gained: raid','announceLevelRaid'}}) do rows[#rows+1]=check(canvas,width,v[1],v[2],nil,false) end
 for _,v in ipairs({{'Quest message','questAnnouncement'},{'Level message','levelAnnouncement'}}) do
  local key,label=v[2],v[1]
  rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label=label,desc=HP.db[key],button='Edit',run=function()editMessage(key,label)end},width)
 end
 rows[#rows+1]=UI.HeaderRow(canvas,'Character statistics',width)
 rows[#rows+1]=check(canvas,width,'Track XP, gold, honor, currencies and dungeon runs','activityTracking','Reload the UI after changing this option.',false)
 if HP.activityRuntime then for _,line in ipairs(HP.ActivitySummaryLines()) do rows[#rows+1]=UI.InfoRow(canvas,line,width) end end
 return rows
end
HP.nativeCommunityPage=community
local function choices(books)
 local list={};for id,b in pairs(books) do list[#list+1]={value=id,label=b.name} end
 table.sort(list,function(a,b)return a.label<b.label end);return list
end
local extras={key='dude-guides',title='Professions, reputation and gathering'}
function extras.build(canvas,width)
 local rows={UI.HeaderRow(canvas,'Guide books',width)}
 rows[#rows+1]=check(canvas,width,'Pause automatic guide progress','paused',nil,false)
 rows[#rows+1]=drop(canvas,width,'Active book',{{value='leveling',label='Leveling / quest guides'},{value='professions',label='Professions (1–300)'},{value='reputation',label='Reputation'}},'guideBook',HP.ChooseGuideBook)
 rows[#rows+1]=drop(canvas,width,'Profession',choices(HP.professionBooks),'professionGuide')
 rows[#rows+1]=check(canvas,width,'Include professions while leveling','includeProfessionsWhileLeveling','Show the current profession step below your quest steps.',false)
 rows[#rows+1]=drop(canvas,width,'Reputation',choices(HP.reputationBooks),'reputationGuide')
 rows[#rows+1]=UI.PageRow(canvas,Cfg,{label='Announcements and statistics',open=function()Cfg:OpenPage(community)end},width)
 rows[#rows+1]=UI.HeaderRow(canvas,'Gathering routes',width)
 local maps={{value='auto',label='Current zone / automatic'}}
 for id in pairs(HP.gatherSeeds) do local info=HP.Call(C_Map and C_Map.GetMapInfo,id);maps[#maps+1]={value=id,label=info and info.name or ('Zone '..id)} end
 table.sort(maps,function(a,b) return tostring(a.value)=='auto' or tostring(b.value)~='auto' and a.label<b.label end)
 rows[#rows+1]=drop(canvas,width,'Gathering zone',maps,'gatherZone')
 local function resources() local list={{value='auto',label='All resources for my skill'}};for id,b in pairs(HP.gatherNodeInfo) do if b.kind==HP.db.professionGuide then list[#list+1]={value=id,label=b.name} end end;return list end
 rows[#rows+1]=drop(canvas,width,'Resource',resources,'gatherResource',function(v) if v=='auto' then HP.db.gatherResource=nil end;HP.InvalidateGathering();HP.Refresh() end)
 rows[#rows+1]=check(canvas,width,'Show known and gathered nodes','gatherShowNodes','Herbs are lime, ore is gold, fishing pools are blue; your gathered spots are green.',true)
 rows[#rows+1]=check(canvas,width,'Remember gathered nodes','gatherRecord','Keep harvesting history per character.',true)
 rows[#rows+1]=check(canvas,width,'Automatic profession waypoint','autoWaypoint',nil,true)
 rows[#rows+1]=UI.HeaderRow(canvas,'Minimap route lines',width)
 rows[#rows+1]=UI.CheckRow(canvas,Cfg,{label='Show route lines',get=function()return not HP.db.hideRouteLines end,set=function(v)HP.db.hideRouteLines=not v;HP.UpdateRouteLines() end},width)
 rows[#rows+1]=UI.CheckRow(canvas,Cfg,{label='Show minimap route lines',get=function()return not HP.db.hideMinimapTrail end,set=function(v)HP.db.hideMinimapTrail=not v;HP.UpdateRouteLines() end},width)
 rows[#rows+1]=check(canvas,width,'Static route lines','staticRouteTrail','Disable line animation.',false)
 rows[#rows+1]=UI.InfoRow(canvas,'Possible gathering spawns are not live nodes. Recently checked spots wait 3 minutes; harvested spots wait 10 minutes. The floating map overlay stays removed.',width)
 return rows
end
HP.nativeExtrasPage=extras
local guideBuild=Cfg.TABS[1].build
Cfg.TABS[1].build=function(canvas,width)
 local rows=guideBuild(canvas,width)
 if HP.Suite then return rows end
 table.insert(rows,1,UI.PageRow(canvas,Cfg,{label='Our additional guide books',desc='Professions, reputation, gathering and minimap route lines.',open=function()Cfg:OpenPage(extras) end},width))
 return rows
end
function D.TogglePause()if not ready() then return end;HP.db.paused=not HP.db.paused;HP.Refresh()end
local bindingBuild=Cfg.TABS[5].build
Cfg.TABS[5].build=function(canvas,width)local rows=bindingBuild(canvas,width);rows[#rows+1]=UI.BindingRow(canvas,Cfg,{label='Pause / resume guide',action='DWMG_DING_PAUSE'},width);return rows end
local oldSlash=SlashCmdList.DUDEWHERESMYDING
local function command(input)
 if not ready() then return oldSlash(input) end
 input=(input or ''):gsub('^%s+',''):gsub('%s+$','')
 if input=='professions' or input=='profession' or input=='reputation' or input=='gather' or input=='gathering' then Cfg:Open('guide');Cfg:OpenPage(extras);return end
 if input=='quests' or input=='leveling' then HP.ChooseGuideBook('leveling');return end
 if input=='pause' then HP.db.paused=not HP.db.paused;HP.Refresh();return end
 return SlashCmdList.DWMGDING(input)
end
SlashCmdList.DUDEWHERESMYDING=command
SLASH_DUDEWHERESMYDING1='/dudeding'
-- Keep /ding available to a separately installed original addon.
SLASH_DWMGDING1='/dwmd'
local createLegacy=HP.CreateUI
function HP.CreateUI(...)
 local result=createLegacy(...)
 if ready() then hideLegacy() end
 return result
end
function HP.MigrateNativeBridge(_,name)
 if name~='WTFDudeSuite' then return end
 if not HP.modulesInitialized then HP.pendingNativeMigration=true;return end
 if not D.db.dude017 then
  D.db.panel.preview=3
  D.db.ui.autoAccept=HP.db and HP.db.autoAcceptQuests==true or false
  D.db.ui.autoTurnin=HP.db and HP.db.autoTurnInQuests==true or false
  D.db.ui.sellGrey=false;D.db.ui.repair=false
  D.db.ui.welcomed=HP.db and HP.db.defaults08==true or false;D.db.ui.setupDone=D.db.ui.welcomed
  D.db.dude017=true
 end
 -- Character migration is separate from account settings, so alts migrate independently.
 if not D.char.dude017 then
  local id=HP.db and HP.db.libraryGuideID
  local old=HP.db and HP.db.routes and id and HP.db.routes['library:'..id]
  local route=id and D:GetGuide(id) and HP.CompileLibraryGuide(id)
  if route then
   local step=route.steps[old and old.index or 1]
   D.char.guide=id;D.char.step=step and step.libraryIndex or #D:GetGuide(id).steps
  end
  if not id or route then D.char.dude017=true end
 end
end
D:On('ADDON_LOADED',HP.MigrateNativeBridge)
D:On('PLAYER_LOGIN',function()
 if not HP.db then return end
 if not HP.frame then HP.DetectCharacter();HP.CreateUI() end
 HP.nativeStarted=true
 HP.db.guideBook=HP.db.guideBook or 'leveling'
 if HP.db.guideBook~='professions' and HP.db.guideBook~='reputation' then HP.db.guideBook='leveling' end
 HP.db.professionGuide=HP.professionBooks[HP.db.professionGuide] and HP.db.professionGuide or 'Herbalism'
 HP.db.reputationGuide=HP.reputationBooks[HP.db.reputationGuide] and HP.db.reputationGuide or 529
 hideLegacy();HP.Refresh();HP.CheckQuestAnnouncements(true);HP.RecordXP()
 HP.markers={};HP.areas={}
 local ticker=CreateFrame('Frame');HP.nativeBridgeTicker=ticker;local elapsed,fallbackElapsed=0,0
 ticker:SetScript('OnUpdate',function(_,dt)
  if not ready() then return end
  HP.db.levelElapsed=(HP.db.levelElapsed or 0)+dt
  elapsed=elapsed+dt;if elapsed<.1 then return end;elapsed=0
  fallbackElapsed=fallbackElapsed+.1
  if D.Arrow.fallbackActive and fallbackElapsed>=.5 then fallbackElapsed=0;D.Arrow:Update() end
  HP.UpdateRouteLines()
  if HP.frame and (HP.frame.actionTarget:IsShown()or HP.frame.actionUse:IsShown())then hideLegacy()end
 end)
 -- Legacy settings buttons all redirect here; only the native settings window is exposed.
 if HP.frame then HP.frame:HookScript('OnShow',hideLegacy) end
 if HP.settings then HP.settings:HookScript('OnShow',function(self)self:Hide();Cfg:Open('guide') end) end
 if HP.minimapButton then HP.minimapButton:HookScript('OnShow',function(self)self:Hide() end) end
 if type(SetBinding)=='function' and type(GetBindingKey)=='function' and not D.char.bindingMigration017 then
  local changed=false
  for old,new in pairs({DWMG_DING_NEXT='DWMGDING_NEXT',DWMG_DING_PREVIOUS='DWMGDING_PREV',DWMG_DING_TOGGLE='DWMGDING_TOGGLE',DWMG_DING_SETTINGS='DWMGDING_CONFIG'}) do
   local keys={GetBindingKey(old)}
   for _,key in ipairs(keys) do if type(key)=='string' and HP.Call(SetBinding,key,new)~=false then changed=true end end
  end
  if changed then HP.Call(SaveBindings,HP.Call(GetCurrentBindingSet) or 1) end
  D.char.bindingMigration017=true
 end
 -- The native guide menu includes next steps immediately (configurable from 0 to 3).
end)
