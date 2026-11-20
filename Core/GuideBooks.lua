local _,HP=...
local function wide(fn,...)
 if type(fn)~='function' then return end;local r={pcall(fn,...)};if not r[1] then return end
 for i=2,18 do if not HP.Public(r[i]) then r[i]=nil end end;return unpack(r,2,18)
end
HP.ReadGuideAPI=wide
function HP.ImportStandaloneProgress()
 if type(DudeWheresMyGuildLevelingDB)=='table' and DudeWheresMyGuildLevelingDB.guildIntegrationUsed and not (DudeWheresMyDingDB and DudeWheresMyDingDB.standaloneReturn012) then
  local function copy(v) if type(v)~='table' then return v end;local t={};for k,x in pairs(v) do t[k]=copy(x) end;return t end
  DudeWheresMyDingDB=copy(DudeWheresMyGuildLevelingDB);DudeWheresMyDingDB.standaloneReturn012=true
 end
end
function HP.ReputationState(id)
 local modern=wide(C_Reputation and C_Reputation.GetFactionDataByID,id)
 if type(modern)=='table' then return {name=modern.name,standing=modern.reaction,low=modern.currentReactionThreshold,high=modern.nextReactionThreshold,value=modern.currentStanding,id=id} end
 local direct={wide(GetFactionInfoByID,id)}
 if direct[1] then return {name=direct[1],standing=direct[3],low=direct[4],high=direct[5],value=direct[6],id=id} end
 local n=wide(GetNumFactions) or 0
 for i=1,math.min(500,n) do local name,_,standing,low,high,value,_,_,header,_,_,_,_,faction=wide(GetFactionInfo,i)
  if not header and (faction==id or HP.reputationBooks[id] and HP.reputationBooks[id].name==name) then return {name=name,standing=standing,low=low,high=high,value=value,id=id} end
 end
end
function HP.ReputationTask(id)
 if HP.Suite and not HP.Suite:On('reputation') then return end
 local b=HP.reputationBooks[id];if not b then return end;local state=HP.ReputationState(id);local rows={}
 if not state then rows[1]={kind='info',text='Discover '..b.name..' to track its standing.',tooltipText='The game has not exposed a standing for this faction. No reputation is assumed.'};return {book=b,rows=rows,percent=0} end
 local standing=state.standing or 4;local max=state.high or 1;local min=state.low or 0;local val=state.value or min
 if standing>=8 then rows[1]={kind='info',text=b.name..': Exalted.'};return {book=b,rows=rows,state=state,percent=1,complete=true} end
 local band=b.bands[#b.bands];for _,candidate in ipairs(b.bands) do if standing<candidate[1] then band=candidate;break end end
 local name=_G['FACTION_STANDING_LABEL'..standing] or ({'Hated','Hostile','Unfriendly','Neutral','Friendly','Honored','Revered','Exalted'})[standing]
 rows[1]={kind='info',text=name..' · '..math.max(0,val-min)..' / '..math.max(1,max-min),tooltipText='Live standing. The farming method changes when your reputation rank changes.'}
 rows[2]={kind='objective',text=band[2],tooltipText='Classic reputation method. Beta rewards and eligibility may differ; follow live quest and reputation feedback.'}
 -- Battleground and instance coordinates are not presented as overworld entrances.
 local location=not (id==729 or id==510 or id==889 or band[3]=='Molten Core' or band[3]=='Blackrock Mountain') and {mapID=band[4],x=band[5],y=band[6]} or nil
 return {book=b,rows=rows,state=state,location=location,percent=math.max(0,math.min(1,(val-min)/math.max(1,max-min)))}
end
function HP.ChooseGuideBook(kind)
 if kind~='leveling' and kind~='professions' and kind~='reputation' then return end
 if HP.Call(InCombatLockdown) then HP.pendingGuideZone=nil;HP.pendingGuideStyle=nil;HP.pendingGuideBook=kind;print('WTF! DUDE SUITE: guide switch queued until combat ends.');return end
 HP.pendingGuideZone=nil;HP.pendingGuideStyle=nil;HP.pendingGuideBook=nil;HP.db.guideBook=kind;HP.demo=false;HP.professionReview=nil;HP.manualWaypoint=nil;HP.manualWaypointQuestID=nil;HP.HideNPCPreview();HP.Refresh();for unit in pairs(HP.plates or {}) do HP.RefreshPlate(unit) end
end
function HP.DrawAuxiliaryGuide()
 local kind=HP.db.guideBook;local task=kind=='professions' and HP.ProfessionTask(HP.db.professionGuide or 'Herbalism') or HP.ReputationTask(HP.db.reputationGuide or 529)
 if not task then return end
 HP.auxiliaryActive=true;HP.auxTask=task;HP.auxTitle=task.book.name;HP.auxProgress=task.percent or 0;HP.auxRange=kind=='professions' and '1–300' or 'Reputation'
 if HP.Call(InCombatLockdown) then HP.refreshPending=true;return end
 HP.refreshPending=false;if HP.pendingGuideScale then HP.frame:SetScale(HP.db.scale or .9);HP.pendingGuideScale=nil end;if HP.pendingGuideSize then HP.frame:SetWidth(math.max(360,HP.db.width or 410));HP.pendingGuideSize=nil end
 local route,state=HP.route,HP.state;HP.route=nil;HP.state=nil;HP.markers={};HP.areas={};HP.waypoint=nil
 if not HP.db.hidden and not HP.db.paused and (HP.db.autoWaypoint~=false or HP.manualWaypoint) then
  HP.waypoint=HP.manualWaypoint or task.location
  if kind=='professions' and task.step and task.step.gather and not task.fishing and not HP.manualWaypoint and HP.waypoint then
   if task.gatherRoute and not task.gatherRoute.suggested then
    HP.gatherPoint=1;HP.gatherMap=task.step.mapID
   else
   local points=task.gatherRoute and task.gatherRoute.points or HP.gatherLoops[task.step.mapID];HP.gatherPoint=HP.gatherPoint or 1;if HP.gatherMap~=task.step.mapID then HP.gatherMap=task.step.mapID;HP.gatherPoint=1 end
   for attempt=1,#points do
    local p=points[HP.gatherPoint] or points[1];HP.waypoint={mapID=task.step.mapID,x=p[1],y=p[2]};local dx,dy=HP.NavigationVector(HP.waypoint)
    if dx and math.sqrt(dx*dx+dy*dy)<(task.gatherRoute and not task.gatherRoute.suggested and 8 or 30) then HP.gatherPoint=HP.gatherPoint%#points+1 else break end
   end
   end
  end
 end
 if HP.db.hidden then HP.frame:Hide() else HP.frame:Show() end
 if HP.db.hidden then HP.frame.menu:Hide() end;HP.RenderRows(task.book.name,task.rows,'',task.index or 1,task.book.steps and #task.book.steps or 1,HP.auxProgress);HP.UpdateModernPanel();HP.UpdateArrow();HP.UpdateMapPins();HP.HideDetachedControls()
 HP.route,HP.state=route,state
end
local refresh=HP.Refresh
function HP.Refresh(...)
 if HP.db and HP.db.guideBook and HP.db.guideBook~='leveling' and HP.frame and not HP.demo then return HP.DrawAuxiliaryGuide() end
 HP.auxiliaryActive=false;HP.auxTask=nil;return refresh(...)
end
local footer=HP.UpdateXPFooter
function HP.UpdateXPFooter()
 if HP.auxiliaryActive then if HP.frame then HP.frame.progress:SetValue(HP.auxProgress or 0);HP.frame.xpPercent:SetText((HP.db.guideBook=='professions' and (HP.auxTask.rank..'/300 · ') or '')..math.floor((HP.auxProgress or 0)*100)..'%') end;return end;return footer()
end
local move=HP.Move
function HP.Move(delta)
 if HP.auxiliaryActive then if HP.db.guideBook=='professions' and HP.auxTask and HP.auxTask.step and HP.auxTask.step.gather and not HP.auxTask.training and not HP.auxTask.fishing then if HP.MoveGatherStep and HP.MoveGatherStep(delta) then return end;local points=HP.auxTask.gatherRoute and HP.auxTask.gatherRoute.points or HP.gatherLoops[HP.auxTask.step.mapID];if #points>0 then HP.gatherPoint=((HP.gatherPoint or 1)-1+delta)%#points+1;HP.Refresh() end end;return end;return move(delta)
end
local navigation=HP.NavigationInstruction
function HP.NavigationInstruction(fallback) if HP.manualWaypoint then return navigation(fallback) end;if HP.auxiliaryActive and HP.auxTask and HP.auxTask.location then return HP.auxTask.step and HP.auxTask.step.zone or HP.auxTitle end;return navigation(fallback) end
local build=HP.BuildGuideRows
function HP.BuildGuideRows()
 local rows=build();if HP.db.includeProfessionsWhileLeveling then
  local task=HP.ProfessionTask(HP.db.professionGuide or 'Herbalism');if task and not task.complete then local r=task.rows[1];rows[#rows+1]={kind='profession',text=task.book.name..': '..r.text,tooltipText=r.tooltipText,recipeGuide=r.recipeGuide} end
 end;return rows
end
-- Fresh event values refresh skill/standing-driven steps; no profession polling loop.
local create=HP.CreateUI
function HP.CreateUI()
 HP.db.guideStyle=(HP.db.guideStyle=='speed' and 'speed' or 'normal');if not HP.professionBooks[HP.db.professionGuide] then HP.db.professionGuide='Herbalism' end;if not HP.reputationBooks[HP.db.reputationGuide] then HP.db.reputationGuide=529 end;if HP.db.guideBook~='professions' and HP.db.guideBook~='reputation' then HP.db.guideBook='leveling' end;create();HP.db.guideBook=HP.db.guideBook or 'leveling';local f=CreateFrame('Frame');HP.guideBookEvents=f
 local function redraw()
  HP.guideBookUpdatePending=nil;f:SetScript('OnUpdate',nil)
  if HP.db.guideBook~='leveling' or HP.db.includeProfessionsWhileLeveling then HP.Refresh() end
  local p=HP.settings;if p and p:IsShown() and (p.page=='Professions' or p.page=='Reputation') and not (p.bookMenu and p.bookMenu:IsShown()) then p.ShowPage(p.page) end
 end
 HP.frame.progress:EnableMouse(true)
 HP.frame.progress:SetScript('OnEnter',function(self)
  if not GameTooltip then return end;GameTooltip:SetOwner(self,'ANCHOR_TOP')
  if HP.auxiliaryActive then
   GameTooltip:SetText((HP.auxTitle or 'Guide')..' progress');GameTooltip:AddLine(HP.frame.xpPercent:GetText(),1,.85,.4)
   if HP.db.guideBook=='professions' and HP.auxTask then GameTooltip:AddLine('Current training cap: '..HP.auxTask.maximum..'. The percentage is progress toward skill 300.',.85,.9,1,true) end
  else
   GameTooltip:SetText('Character XP: '..HP.frame.xpPercent:GetText())
   if HP.db.showLevelETA then local note=HP.frame.note:GetText();if note and note~='' then GameTooltip:AddLine(note,.85,.9,1,true) end end
  end;GameTooltip:Show()
 end)
 HP.frame.progress:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
 HP.FlushGuideBookUpdate=redraw
 local elapsed=0
 local function tick(_,dt) elapsed=elapsed+dt;if elapsed>=.1 then redraw() end end
 for _,e in ipairs({'SKILL_LINES_CHANGED','TRADE_SKILL_SHOW','TRADE_SKILL_CLOSE','TRADE_SKILL_UPDATE','TRADE_SKILL_LIST_UPDATE','TRADE_SKILL_DATA_SOURCE_CHANGED','CRAFT_SHOW','CRAFT_CLOSE','CRAFT_UPDATE','UPDATE_FACTION','CHAT_MSG_SKILL','BAG_UPDATE_DELAYED','PLAYER_REGEN_ENABLED'}) do pcall(f.RegisterEvent,f,e) end
 f:SetScript('OnEvent',function(_,event)
  HP.profSkillCache=nil;HP.openRecipeCache=nil
  if event=='PLAYER_REGEN_ENABLED' then
   if HP.pendingGuideZone then local id=HP.pendingGuideZone;HP.pendingGuideZone=nil;HP.pendingGuideStyle=nil;HP.pendingGuideBook=nil;HP.SelectGuide(id)
   elseif HP.pendingGuideStyle then local style=HP.pendingGuideStyle;HP.pendingGuideStyle=nil;HP.pendingGuideBook=nil;HP.SetGuideStyle(style)
   elseif HP.pendingGuideBook then local kind=HP.pendingGuideBook;HP.pendingGuideBook=nil;HP.ChooseGuideBook(kind) end
   redraw();return
  end
  if HP.guideBookUpdatePending then return end
  HP.guideBookUpdatePending=true;elapsed=0;f:SetScript('OnUpdate',tick)
 end)
end

local hide=HP.HideDetachedControls
function HP.HideDetachedControls()
 hide();if HP.auxiliaryActive and HP.frame then
  if HP.frame.npcPanel then HP.frame.npcPanel:Hide() end
  if HP.Call(InCombatLockdown) then return end
  if HP.questItemBar then HP.questItemBar:Hide();for _,b in ipairs(HP.questItemBar.inlineButtons or {}) do b:Hide() end end
  for _,b in ipairs(HP.frame.targetButtons or {}) do b:Hide() end
  HP.frame.actionTarget:Hide();HP.frame.actionUse:Hide()
 end
end

local action=HP.NavigationAction
function HP.NavigationAction()
 if HP.manualWaypoint then return 'Manual destination' end
 if HP.auxiliaryActive and HP.auxTask then return HP.auxTask.step and (HP.auxTask.step.recipe..' · skill '..HP.auxTask.step.to) or HP.auxTitle end
 return action()
end

local rescan=HP.RescanCurrentGuide
function HP.RescanCurrentGuide()
 if HP.auxiliaryActive then HP.profSkillCache=nil;HP.openRecipeCache=nil;HP.Refresh();return end
 return rescan()
end

local select=HP.SelectGuide
function HP.SelectGuide(id)
 if not HP.routes[id] then return end;if HP.Call(InCombatLockdown) then HP.pendingGuideBook=nil;HP.pendingGuideStyle=nil;HP.pendingGuideZone=id;return end
 HP.db.guideBook='leveling';HP.db.normalManualGuide=id;return select(id)
end
local map=HP.CurrentGuideMap
function HP.CurrentGuideMap()
 if HP.db and HP.db.guideStyle=='normal' and HP.db.normalManualGuide and HP.routes[HP.db.normalManualGuide] then return HP.routes[HP.db.normalManualGuide].mapID end
 return map()
end
local mode=HP.SetGuideStyle
function HP.SetGuideStyle(style)
 if style~='normal' and style~='speed' then return end
 if HP.Call(InCombatLockdown) then HP.pendingGuideBook=nil;HP.pendingGuideZone=nil;HP.pendingGuideStyle=style;return end
 HP.db.guideBook='leveling';HP.db.normalManualGuide=nil;return mode(style)
end

local panelUpdate=HP.UpdateModernPanel
function HP.UpdateModernPanel() panelUpdate();HP.UpdateXPFooter() end

-- Auxiliary navigation never writes quest-arrival history or borrows a quest path.
local arrival=HP.CheckArrival
function HP.CheckArrival() if HP.auxiliaryActive then return end;return arrival() end
local dynamic=HP.UpdateDynamicDestination
function HP.UpdateDynamicDestination()
 if not HP.auxiliaryActive then return dynamic() end
 local task=HP.auxTask
 if not task or task.training or task.fishing or not task.step or not task.step.gather or not HP.waypoint or HP.db.autoWaypoint==false or HP.db.hidden or HP.db.paused or HP.manualWaypoint then return end
 local dx,dy=HP.NavigationVector(HP.waypoint);if dx and dx*dx+dy*dy<900 then HP.Refresh() end
end
local plate=HP.RefreshPlate
function HP.RefreshPlate(unit)
 if HP.auxiliaryActive then if HP.plates[unit] then HP.plates[unit]:Hide() end;return end
 return plate(unit)
end

local sync=HP.Sync
function HP.Sync(...)
 if HP.auxiliaryActive and HP.db.guideBook~='leveling' then return HP.RescanCurrentGuide() end
 return sync(...)
end
