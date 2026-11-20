local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local function button(parent,title,x,y,w,click)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');b:SetPoint('TOPLEFT',parent,'TOPLEFT',x,-y);b:SetSize(w,30);b:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});b:SetBackdropColor(.13,.09,.05,1);b:SetBackdropBorderColor(.56,.41,.22,1)
 b.bg=b:CreateTexture(nil,'BACKGROUND');b.bg:SetAllPoints();b.bg:SetTexture(WHITE);b.bg:SetVertexColor(.13,.09,.05,1);b.label=b:CreateFontString(nil,'OVERLAY');b.label:SetFont('Fonts\\FRIZQT__.TTF',12);b.label:SetPoint('LEFT',9,0);b.label:SetWidth(w-18);b.label:SetText(title);b.label:SetTextColor(.96,.89,.72);b:SetScript('OnClick',click);b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD');return b
end
function HP.ChooseBookOption(anchor,choices,callback)
 local p=HP.settings
 if not p.bookMenu then
  local m=CreateFrame('Frame',nil,p,'BackdropTemplate');p.bookMenu=m;m:SetFrameLevel(p:GetFrameLevel()+60);m:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});m:SetBackdropColor(.04,.025,.018,1);m:SetBackdropBorderColor(.7,.5,.25,1);m.scroll=CreateFrame('ScrollFrame',nil,m,'UIPanelScrollFrameTemplate');m.scroll:SetPoint('TOPLEFT',4,-4);m.scroll:SetPoint('BOTTOMRIGHT',-26,4);m.content=CreateFrame('Frame',nil,m.scroll);m.content:SetWidth(470);m.scroll:SetScrollChild(m.content);m.rows={};m:Hide()
 end
 local m=p.bookMenu;m:ClearAllPoints();m:SetPoint('TOPLEFT',anchor,'BOTTOMLEFT',0,-2);m:SetSize(510,math.min(330,8+#choices*29));for _,b in ipairs(m.rows) do b:Hide() end
 for i,c in ipairs(choices) do local b=m.rows[i];if not b then b=button(m.content,'',0,(i-1)*29,470,function() end);m.rows[i]=b end;b.label:SetText(c.label);b:SetScript('OnClick',function() m:Hide();callback(c.value) end);b:Show() end
 m.content:SetHeight(math.max(1,#choices*29));m.scroll:SetVerticalScroll(0);m:Show()
end
local extra=HP.RenderExtraSettingsPage
function HP.RenderExtraSettingsPage(p,page,line,control,existing)
 if p.bookMenu then p.bookMenu:Hide() end
 if p.professionMap then p.professionMap:Hide() end
 if page=='Professions' then
  local selected=HP.professionBooks[HP.db.professionGuide] and HP.db.professionGuide or 'Herbalism';HP.db.professionGuide=selected
  local task=HP.ProfessionTask(selected);line('Skill '..task.rank..'/300 · current training cap '..task.maximum..'. Live gains advance the guide.',12,0,-40):SetHeight(36)
  local chooser
  chooser=control(selected..' · '..task.rank..'/300   v',-83,function()
   local choices={};local skills=HP.ProfessionSkills();for name,b in pairs(HP.professionBooks) do local s=skills[b.skillID];choices[#choices+1]={label=name..' · '..(s and (s.rank..'/'..s.maximum) or 'Not learned'),value=name} end;table.sort(choices,function(a,b) return a.label<b.label end)
   HP.ChooseBookOption(chooser,choices,function(name) HP.db.professionGuide=name;HP.gatherMap=nil;HP.gatherPoint=1;p.ShowPage('Professions');HP.Refresh() end)
  end)
  control(HP.db.guideBook=='professions' and 'Profession-only guide: |cff55ee77ON|r' or 'Start profession-only guide',-124,function() HP.ChooseGuideBook(HP.db.guideBook=='professions' and 'leveling' or 'professions');p.ShowPage('Professions') end)
  existing(p.includeProfToggle,-165);p.includeProfToggle:Refresh()
  local y=-213
  if task then for _,r in ipairs(task.rows) do line(r.text,13,0,y):SetHeight(40);y=y-43 end end
  if task and task.recipeGuide then
   p.recipePreview.estimate=task.recipeGuide;existing(p.recipePreview,y);if HP.ReadGuideAPI(GameTooltip and GameTooltip.IsOwned,GameTooltip,p.recipePreview) then HP.ShowProfessionRecipeTooltip(p.recipePreview,task.recipeGuide) end;y=y-44
   for _,r in ipairs(task.recipeGuide.reagents) do line(HP.ProfessionMaterialText(r),12,0,y):SetHeight(42);y=y-45 end
   line(task.recipeGuide.source,11,0,y):SetHeight(56);y=y-63
  end
  if task and not task.training and task.step and task.step.gather and HP.BuildGatherMap then HP.BuildGatherMap(p,task.step.mapID,0,y-9,task);y=y-245 end
  line('Craft counts are estimates, with spare materials for missed skill-ups. Stop at the target; open your profession to check beta recipe changes.',11,0,y-9):SetHeight(65)
  p.content:SetHeight(math.max(470,-y+85));return true
 elseif page=='Reputation' then
  line('Choose a faction. Methods follow your current standing.',12,0,-40):SetHeight(35)
  local id=HP.reputationBooks[HP.db.reputationGuide] and HP.db.reputationGuide or 529;HP.db.reputationGuide=id;local chooser
  chooser=control(HP.reputationBooks[id].name..'   v',-83,function()
   local choices={};for faction,b in pairs(HP.reputationBooks) do local s=HP.ReputationState(faction);choices[#choices+1]={value=faction,label=b.name..' · '..(s and (_G['FACTION_STANDING_LABEL'..(s.standing or 4)] or 'Discovered') or 'Undiscovered')} end;table.sort(choices,function(a,b) return a.label<b.label end)
   HP.ChooseBookOption(chooser,choices,function(value) HP.db.reputationGuide=value;p.ShowPage('Reputation');HP.Refresh() end)
  end)
  control(HP.db.guideBook=='reputation' and 'Reputation guide: |cff55ee77ON|r' or 'Start reputation guide',-125,function() HP.ChooseGuideBook(HP.db.guideBook=='reputation' and 'leveling' or 'reputation');p.ShowPage('Reputation') end)
  local task=HP.ReputationTask(id);local y=-181;for _,r in ipairs(task.rows) do line(r.text,13,0,y):SetHeight(77);y=y-88 end
  line('Live standings decide when the next method appears. Reputation rewards in the beta can differ from Classic.',11,0,y):SetHeight(60);p.content:SetHeight(math.max(470,-y+90));return true
 elseif page=='Leveling' then
  line('Questing guidebooks',16,0,-45)
  control('Resume leveling guide',-89,function() HP.ChooseGuideBook('leveling');HP.UseGuide();p:Hide() end)
  control('Normal / all indexed zone quests',-132,function() HP.SetGuideStyle('normal');p.ShowPage('Chapters') end)
  control('Speedrun / Classic quests only',-175,function() HP.SetGuideStyle('speed');p.ShowPage('Chapters') end)
  control('Browse chapters and zones',-218,function() p.ShowPage('Chapters') end)
  local n,_,new=HP.ModeCoverage();line(n..' indexed quests · '..new..' Forever quests\nAccepted quests missing from the index use the live quest log. Unverified locations are kept out of pickup navigation.',12,0,-279):SetHeight(106);p.content:SetHeight(470);return true
 elseif page=='Home' then
  line("DUDE, WHERE'S MY DING?",21,0,-47);line('One clear step. Your next ding.',14,0,-88)
  control('Leveling guidebooks',-145,function() p.ShowPage('Leveling') end);control('Profession guidebooks',-187,function() p.ShowPage('Professions') end);control('Reputation guidebooks',-229,function() p.ShowPage('Reputation') end)
  control('Return to leveling tracker',-294,function() HP.ChooseGuideBook('leveling');p:Hide() end)
  line('Normal questing, Classic speedrun candidates, skill-driven profession steps and live reputation goals.',12,0,-357):SetHeight(72);p.content:SetHeight(470);return true
 end
 return extra(p,page,line,control,existing)
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local p=HP.settings;p:SetSize(900,650)
 local regions={};if type(p.GetRegions)=='function' then regions={p:GetRegions()} end;for _,r in ipairs(regions) do if r.Hide then r:Hide() end end
 local bg=p:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetTexture(WHITE);bg:SetVertexColor(.045,.029,.019,1)
 local side=p:CreateTexture(nil,'BORDER');side:SetPoint('TOPLEFT',p,'TOPLEFT',5,-45);side:SetPoint('BOTTOMLEFT',p,'BOTTOMLEFT',5,5);side:SetWidth(202);side:SetTexture(WHITE);side:SetVertexColor(.075,.045,.025,1)
 local children={};if type(p.GetChildren)=='function' then children={p:GetChildren()} end
 local keep={[p.scroll]=true,[p.search]=true,[p.titleBar]=true};for _,b in pairs(p.navigationButtons) do keep[b]=true end
 for _,child in ipairs(children) do if not keep[child] then child:Hide() end end
 p.scroll:ClearAllPoints();p.scroll:SetPoint('TOPLEFT',p,'TOPLEFT',226,-83);p.scroll:SetPoint('BOTTOMRIGHT',p,'BOTTOMRIGHT',-28,20);p.content:SetWidth(640)
 p.search:ClearAllPoints();p.search:SetPoint('TOPLEFT',p,'TOPLEFT',20,-64);p.search:SetWidth(170)
 local headings={{'GUIDEBOOKS',116},{'SETTINGS',339}};for _,h in ipairs(headings) do local t=p:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',10);t:SetPoint('TOPLEFT',p,'TOPLEFT',18,-h[2]);t:SetText(h[1]);t:SetTextColor(.85,.67,.36) end
 local nav={{'Home','Overview',140},{'Leveling','Leveling',174},{'Professions','Professions',208},{'Reputation','Reputation',242},{'Chapters','Chapters / zones',276},{'Guide Mode','Guide mode',310},{'Navigation','Navigation',364},{'Map','Map & gathering',398},{'Display','Display',432},{'Options','Quest & target',466},{'Announcements','Announcements',500}}
 for _,r in ipairs(nav) do local name,title,y=r[1],r[2],r[3];local b=p.navigationButtons[name];if not b then b=button(p,title,14,y,184,function() p.ShowPage(name) end);p.navigationButtons[name]=b end;b:ClearAllPoints();b:SetPoint('TOPLEFT',p,'TOPLEFT',14,-y);b:SetSize(184,29);b.label:SetText(title) end
 if not HP.db.soundChoice0121 then HP.db.targetSoundChoice=HP.db.targetSoundID==(SOUNDKIT and SOUNDKIT.READY_CHECK or 8960) and 2 or 1;HP.db.soundChoice0121=true end
 p.soundChoice:SetScript('OnClick',function() HP.db.targetSoundChoice=(HP.db.targetSoundChoice==1 and 2 or 1);HP.db.targetSoundID=HP.db.targetSoundChoice==1 and (SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959) or (SOUNDKIT and SOUNDKIT.READY_CHECK or 8960);HP.Call(PlaySound,HP.db.targetSoundID,'Master');p.ShowPage('Options') end)
 p.compact:SetScript('OnClick',function() HP.db.width=410;HP.db.autoFitStep=true;if HP.Call(InCombatLockdown) then HP.pendingGuideSize=true else HP.frame:SetWidth(410) end;HP.Refresh();p.ShowPage('Display') end)
 p.titleBar:SetHeight(34);p.windowTitle:SetWidth(770);p.windowTitle:SetHeight(24);p.windowTitle:SetJustifyH('CENTER');p.windowTitle:SetText("DUDE, WHERE'S MY DING?");p.windowTitle:SetFont('Fonts\\FRIZQT__.TTF',16)
 local version=p:CreateFontString(nil,'OVERLAY');version:SetFont('Fonts\\FRIZQT__.TTF',10);version:SetPoint('BOTTOMRIGHT',p,'BOTTOMRIGHT',-22,8);version:SetText('v'..(HP.GetDingVersion and HP.GetDingVersion() or '0.19.2'));version:SetTextColor(.7,.65,.55)
 p.includeProfToggle=button(p.content,'Include professions while leveling',0,0,510,function() HP.db.includeProfessionsWhileLeveling=not HP.db.includeProfessionsWhileLeveling;p.includeProfToggle:Refresh();HP.Refresh() end)
 local toggle=p.includeProfToggle;toggle.track=CreateFrame('Frame',nil,toggle,'BackdropTemplate');toggle.track:SetSize(64,20);toggle.track:SetPoint('RIGHT',toggle,'RIGHT',-8,0);toggle.track:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});toggle.state=toggle.track:CreateFontString(nil,'OVERLAY');toggle.state:SetFont('Fonts\\FRIZQT__.TTF',10);toggle.state:SetAllPoints();toggle.state:SetJustifyH('CENTER')
 function toggle:Refresh() local on=HP.db.includeProfessionsWhileLeveling;self.track:SetBackdropColor(on and .06 or .23,on and .55 or .12,on and .16 or .10,1);self.state:SetText(on and 'ON' or 'OFF') end
 p.controls[#p.controls+1]=toggle;toggle:Refresh();toggle:Hide()
 p.recipePreview=button(p.content,'Recipe & materials (hover)',0,0,510,function(self) HP.ShowProfessionRecipeTooltip(self,self.estimate) end)
 p.recipePreview:SetScript('OnEnter',function(self) HP.ShowProfessionRecipeTooltip(self,self.estimate) end)
 p.recipePreview:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
 p.controls[#p.controls+1]=p.recipePreview;p.recipePreview:Hide()
 p.searchIcon=p.search:CreateTexture(nil,'OVERLAY');p.searchIcon:SetTexture('Interface\\Common\\UI-Searchbox-Icon');p.searchIcon:SetSize(14,14);p.searchIcon:SetPoint('LEFT',2,0)
 p.search:SetTextInsets(19,3,0,0);p.searchHint=p.search:CreateFontString(nil,'OVERLAY');p.searchHint:SetFont('Fonts\\FRIZQT__.TTF',10);p.searchHint:SetPoint('LEFT',20,0);p.searchHint:SetText('Search chapters');p.searchHint:SetTextColor(.6,.6,.6)
 local change=p.search:GetScript('OnTextChanged');p.search:SetScript('OnTextChanged',function(self,user) if self:GetText()=='' then p.searchHint:Show() else p.searchHint:Hide() end;if change then change(self,user) end end)
 local closing=p:GetScript('OnHide');p:SetScript('OnHide',function(self,...) if self.bookMenu then self.bookMenu:Hide() end;if GameTooltip then GameTooltip:Hide() end;if closing then closing(self,...) end end)
 p.ShowPage('Home')
end

local style=HP.StyleSettingsPage
function HP.StyleSettingsPage(p)
 style(p);if p.soundChoice then p.soundChoice.label:SetText('Target alert sound: '..(HP.db.targetSoundChoice==2 and 'Ready check' or 'Raid warning')..' · click to preview') end;for _,b in ipairs(p.controls or {}) do if b.switchTrack then local on=b.switchTrack.enabled;b.switchTrack:SetBackdropColor(on and .05 or .22,on and .52 or .12,on and .15 or .09,1) end end;p:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});p:SetBackdropColor(.065,.04,.025,1);p:SetBackdropBorderColor(.60,.43,.22,1)
end
