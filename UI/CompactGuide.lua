local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local score=HP.CandidateScore
function HP.CandidateScore(step) local q=HP.questData[step.questID];if q and q.prerequisitesUnverified and not HP.Active(step.questID) then return end;return score(step) end
local location=HP.StepLocation
function HP.StepLocation(step)
 local found=location(step);if found then return found end;local phase=HP.QuestStepPhase(step);local q=HP.questData[step.questID];if q then if phase.action=='accept' then return q.startLocation elseif phase.action=='turnin' then return q.finishLocation end end
end
local colors={quest='69ccf0',npc='ff7867',zone='ffd26a',item='75d7ff',action='eee6d2'}
local function paint(text,kind) return '|cff'..(colors[kind] or colors.action)..tostring(text or '')..'|r' end
local function short(text)
 return (text or ''):gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):gsub('%s+%d+%.%d+%s*[, ]%s*%d+%.%d+',''):gsub('%s+%(%d+%.%d+,%s*%d+%.%d+%)','')
end
local oldRows=HP.StepRows
function HP.StepRows(step,compact)
 local phase=HP.QuestStepPhase(step);local q=HP.questData[step.questID]
 if q and not compact and (phase.action=='accept' or phase.action=='turnin') then
  local id=phase.action=='accept' and q.start or q.finish;local npc=id and HP.npcData[id];local contact=npc and npc.name or (phase.action=='accept' and q.startName or q.finishName);local loc=HP.StepLocation(step);local map=loc and HP.Call(C_Map and C_Map.GetMapInfo,loc.mapID)
  local zone=map and map.name or q.zone or (HP.route and (HP.route.zone or HP.route.title:gsub('%s*%b()','')))
  local out={};if zone then out[#out+1]={kind='travel',text='Go to '..paint(zone,'zone')..'.',tooltipText='Follow the navigation arrow and dotted route. Coordinates are kept out of the instruction text.'} end
  if contact and contact~='' then out[#out+1]={kind='talk',text='Talk to '..paint(contact,'npc')..'.',entityKind=id and 'npc' or nil,entityID=id,entityName=contact,tooltipText='Hover the target icon for the NPC model and details.'} end
  out[#out+1]={kind=phase.action,text=(phase.action=='accept' and 'Accept ' or 'Turn in ')..paint(HP.QuestName(step.questID),'quest')..'.',questID=step.questID}
  return out
 end
 local out={};for _,r in ipairs(oldRows(step,compact)) do if r.kind~='tip' then r.text=short(r.text);out[#out+1]=r end end;return out
end
local included=HP.SpeedQuestIncluded
function HP.SpeedQuestIncluded(step,route) local q=HP.questData[step.questID];if q and q.newForever then return false end;return included(step,route) end
local function skin(f)
 f:SetBackdrop({bgFile=WHITE,edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=12,insets={left=3,right=3,top=3,bottom=3}});f:SetBackdropColor(.025,.019,.016,.96);f:SetBackdropBorderColor(.58,.49,.31,1)
end
local function label(parent,size)
 local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',size,'OUTLINE');t:SetTextColor(.96,.90,.75);return t
end
function HP.CompactTargets()
 local f=HP.frame;if not f or HP.Call(InCombatLockdown) then return end
 for _,b in ipairs(f.targetButtons or {}) do b:Hide() end
 if HP.auxiliaryActive or HP.db.hidden or HP.db.paused then return end
 local count=0;local left=HP.Call(f.GetLeft,f);local scale=HP.Call(f.GetEffectiveScale,f) or 1;local parentScale=HP.Call(UIParent.GetEffectiveScale,UIParent) or 1
 for i,data in ipairs(f.compactRows or {}) do local row=f.rows[i]
  if row and row:IsShown() and (data.kind=='talk' or data.kind=='objective' or data.kind=='kill' or data.kind=='collect') and not data.done then
   local id,name=row.entityID,row.entityName
   if row.entityKind=='item' then local item=HP.itemData[id];id=item and item.mobs and item.mobs[1];name=id and HP.npcData[id] and HP.npcData[id].name end
   if id and name and (row.entityKind=='npc' or row.entityKind=='item') then
    count=count+1;local b=f.targetButtons[count];if not b then break end
    b.npcID=id;b.npcName=name;b:SetScale(scale/parentScale);b:SetSize(26,26);b:SetAttribute('macrotext','/targetexact '..name:gsub('[\r\n]','')..(HP.db.markOnClick and '\n/tm [@target,harm,nodead] 8' or ''));b:ClearAllPoints()
    local y=-(86+(row.offset or 0)-(f.scroll:GetVerticalScroll() or 0));local inside=left and left<34
    b:SetPoint(inside and 'TOPLEFT' or 'TOPRIGHT',f,'TOPLEFT',inside and 7 or -6,y)
    if -(y)<f:GetHeight()-65 and -y>=83 then b:Show() end
   end
  end
 end
end
function HP.CompactLayout()
 local f=HP.frame;if not f or not f.compactTitle then return end
 local aux=HP.auxiliaryActive;local route=HP.route;local zone=aux and HP.auxTitle or route and (route.zone or route.title:gsub('%s*%b()','')) or 'Quest log'
 local range=aux and HP.auxRange or route and ((route.minLevel or 1)..'–'..(route.maxLevel or 60)) or ''
 local title=(range~='' and range..'  ' or '')..zone;f.compactTitle:SetText(title);f.compactTitle:SetFont('Fonts\\FRIZQT__.TTF',#title>32 and 12 or 15,'OUTLINE')
 f.progress:SetStatusBarColor(.78,.055,.075,1);f.xpPercent:SetFont('Fonts\\FRIZQT__.TTF',12,'OUTLINE');f.xpPercent:SetTextColor(1,.94,.84)
 if f.pause.compactGlyph then f.pause.compactGlyph:SetText(HP.db.paused and '>' or '||||') end;f.levelRange:Hide();f.tab:Hide();f.previousStep:Hide();f.nextStep:Hide();f.skipStep:Hide();f.rewardHeading:Hide();f.groupIcon:Hide();f.groupNote:Hide();f.note:Hide()
 if HP.Call(InCombatLockdown) then return end
 local canMove=not aux or (HP.auxTask and HP.auxTask.step and HP.auxTask.step.gather and not HP.auxTask.training and not HP.auxTask.fishing)
 f.previous:SetEnabled(canMove==true);f.next:SetEnabled(canMove==true)
 local w=f:GetWidth();local footer=aux and 34 or 62;HP.guideFooterHeight=footer;HP.guideHeaderHeight=89
 f.referenceBody:ClearAllPoints();f.referenceBody:SetPoint('TOPLEFT',f,'TOPLEFT',5,-84);f.referenceBody:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-5,3)
 f.scroll:ClearAllPoints();f.scroll:SetPoint('TOPLEFT',f.referenceBody,'TOPLEFT',6,-5);f.scroll:SetPoint('BOTTOMRIGHT',f.referenceBody,'BOTTOMRIGHT',-6,footer)
 for _,b in ipairs({f.rewardXP,f.rewardMoney}) do if aux then b:Hide() else b:Show() end end
 for i,b in ipairs({f.rewardXP,f.rewardMoney}) do b:ClearAllPoints();b:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',12+(i-1)*(w-24)/2,34);b:SetSize((w-30)/2,19);b.label:SetFont('Fonts\\FRIZQT__.TTF',10);b.label:SetWidth((w-30)/2-32) end
 local buttons=aux and {f.setWaypoint} or {f.setWaypoint,f.actionTarget,f.actionUse};local widths=aux and {w-24} or {(w-36)*.44,(w-36)*.24,(w-36)*.32};local x=12
 for i,b in ipairs(buttons) do b:ClearAllPoints();b:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',x,7);b:SetSize(widths[i],24);b.label:SetFont('Fonts\\FRIZQT__.TTF',10);b.label:SetWidth(widths[i]-24);x=x+widths[i]+6 end
 if aux then f.actionTarget:Hide();f.actionUse:Hide();local on=HP.db.autoWaypoint~=false and HP.waypoint~=nil;f.setWaypoint.label:SetTextColor(on and .3 or .7,on and 1 or .7,.35) end
 f.setWaypoint.label:SetText(HP.db.autoWaypoint~=false and 'Auto Waypoint' or 'Waypoint OFF')
 local top=0
 for i,data in ipairs(f.compactRows or {}) do local row=f.rows[i]
  if row then
   row.detailTip=not HP.db.hideTips and data.tooltipText or nil;row.recipeGuide=data.recipeGuide;if row.recipeGuide and HP.ReadGuideAPI and HP.ReadGuideAPI(GameTooltip and GameTooltip.IsOwned,GameTooltip,row) then HP.ShowProfessionRecipeTooltip(row,row.recipeGuide) end;row.text:SetFont('Fonts\\FRIZQT__.TTF',data.cardHeader and 12 or 11);row.text:SetTextColor(1,1,1);row.text:ClearAllPoints();row.text:SetPoint('TOPLEFT',row,'TOPLEFT',data.kind=='objective' and 27 or 7,-3);row.text:SetWidth(w-(data.kind=='objective' and 64 or 44));row.icon:Hide();row.symbol:Hide()
   if row.objectiveCheck then if data.kind=='objective' then row.objectiveCheck:Show();row.objectiveCheck:SetPoint('TOPLEFT',row,'TOPLEFT',3,-1);row.objectiveCheck:SetSize(20,20) else row.objectiveCheck:Hide() end end
   local h=math.max(20,(row.text:GetStringHeight() or 15)+6);row:SetHeight(h);row:ClearAllPoints();row:SetPoint('TOPLEFT',f.content,'TOPLEFT',0,-top);row.offset=top;top=top+h
  end
 end
 for _,card in ipairs(f.cards or {}) do card:Hide() end
 f.content:SetHeight(math.max(1,top));f.currentBottom=top
 if HP.db.autoFitStep~=false then local h=math.max(174,math.min(720,89+top+footer+8));if math.abs(f:GetHeight()-h)>1 then HP.AnchorGuideTop();f:SetHeight(h) end end
 local center=HP.Call(f.GetCenter,f);local screen=HP.Call(UIParent.GetWidth,UIParent) or 1920
 f.npcPanel:ClearAllPoints();if center and center>screen/2 then f.npcPanel:SetPoint('TOPRIGHT',f,'TOPLEFT',-38,-84) else f.npcPanel:SetPoint('TOPLEFT',f,'TOPRIGHT',8,-84) end
 HP.CompactTargets()
end
local update=HP.UpdateModernPanel
function HP.UpdateModernPanel() update();HP.CompactLayout() end
local render=HP.RenderRows
function HP.RenderRows(tab,rows,note,current,total,progress)
 local out={};for _,r in ipairs(rows) do if r.kind~='tip' and not r.cardHeader then
  local t={};for k,v in pairs(r) do t[k]=v end
  if t.kind=='objective' then t.text=paint(t.text,'item') elseif not t.text:find('|cff',1,true) then t.text=paint(short(t.text),t.kind=='objective' and 'item' or t.kind=='talk' and 'npc' or 'action') end
  out[#out+1]=t
 end end
 if #out==0 then out[1]={kind='info',text='No unfinished steps in this guide.'} end
 if HP.frame then HP.frame.compactRows=out end;local fit=HP.db.autoFitStep;HP.db.autoFitStep=false;render(tab,out,note,current,total,progress);HP.db.autoFitStep=fit;HP.CompactLayout()
end
local tooltip=HP.ShowRowTooltip
function HP.ShowRowTooltip(row)
 if row.recipeGuide and HP.ShowProfessionRecipeTooltip then HP.ShowProfessionRecipeTooltip(row,row.recipeGuide);return end
 tooltip(row);if GameTooltip and row.detailTip then GameTooltip:AddLine(row.detailTip,.85,.88,.93,true);GameTooltip:Show() end
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local f=HP.frame;HP.guideHeaderHeight=89;HP.guideFooterHeight=62
 if not HP.db.compactLayout012 then HP.db.width=410;HP.db.autoFitStep=true;HP.db.compactLayout012=true end;f:SetWidth(math.max(360,HP.db.width or 410));if f.SetResizeBounds then f:SetResizeBounds(360,174,850,720) end
 f.referenceAvatar:SetSize(64,64);f.referenceAvatar:ClearAllPoints();f.referenceAvatar:SetPoint('TOPLEFT',f,'TOPLEFT',3,-20);f.portrait:SetSize(53,53);f.referenceLevelMedallion:SetSize(26,26);f.levelBadge:SetFont('Fonts\\FRIZQT__.TTF',14)
 local h=f.referenceHeaderFrame;h:ClearAllPoints();h:SetPoint('TOPLEFT',f,'TOPLEFT',61,-24);h:SetPoint('TOPRIGHT',f,'TOPRIGHT',-5,-24);h:SetHeight(55);skin(h);skin(f.referenceBody);for _,panel in ipairs({h,f.referenceBody,f.referenceStepTab}) do for _,t in ipairs(panel.referenceOutline or {}) do t:Hide() end end;f.referenceStepTab:SetBackdrop(nil)
 for _,b in ipairs({f.setWaypoint,f.actionTarget,f.actionUse}) do if b.fill then b.fill:SetVertexColor(.14,.065,.035,.8) end end
 f.compactTitle=label(h,15);f.compactTitle:SetPoint('TOPLEFT',h,'TOPLEFT',5,-8);f.compactTitle:SetPoint('TOPRIGHT',h,'TOPRIGHT',-65,-8);f.compactTitle:SetHeight(21);f.compactTitle:SetJustifyH('CENTER')
 f.referenceStepTab:ClearAllPoints();f.referenceStepTab:SetPoint('TOPLEFT',f,'TOPLEFT',73,-2);f.referenceStepTab:SetSize(122,18);f.step:SetFont('Fonts\\FRIZQT__.TTF',11)
 f.progress:ClearAllPoints();f.progress:SetPoint('BOTTOMLEFT',h,'BOTTOMLEFT',9,8);f.progress:SetPoint('BOTTOMRIGHT',h,'BOTTOMRIGHT',-9,8);f.progress:SetHeight(12)
 f.xpPercent:Hide();f.xpPercent=label(f.progress,12);f.xpPercent:SetAllPoints();f.xpPercent:SetJustifyH('CENTER');f.xpPercent:SetJustifyV('MIDDLE')
 for i,b in ipairs({f.previous,f.next}) do b:ClearAllPoints();b:SetPoint('TOPRIGHT',h,'TOPRIGHT',i==1 and -35 or -7,-6);b:SetSize(25,25) end
 f.headerControls:SetSize(98,22);f.headerControls:ClearAllPoints();f.headerControls:SetPoint('TOPRIGHT',f,'TOPRIGHT',-28,-1)
 for i,b in ipairs({f.settingsButton,f.rescan,f.pause}) do b:SetParent(f.headerControls);b:ClearAllPoints();b:SetPoint('TOPLEFT',f.headerControls,'TOPLEFT',(i-1)*33,0);b:SetSize(29,22);skin(b);if b.label then b.label:Hide() end end
 f.settingsButton.icon:SetSize(18,18);f.settingsButton.icon:ClearAllPoints();f.settingsButton.icon:SetPoint('CENTER')
 f.pause.compactGlyph=label(f.pause,13);f.pause.compactGlyph:SetAllPoints();f.pause.compactGlyph:SetJustifyH('CENTER');f.pause.compactGlyph:SetText('||||')
 f.closeNative:ClearAllPoints();f.closeNative:SetPoint('TOPRIGHT',f,'TOPRIGHT',-4,0);f.closeNative:SetSize(21,21)
 local drag=f:GetScript('OnDragStop');f:SetScript('OnDragStop',function(self,...) if drag then drag(self,...) end;HP.CompactLayout() end)
 local avatarDrag=f.referenceAvatar:GetScript('OnDragStop');f.referenceAvatar:SetScript('OnDragStop',function(self,...) if avatarDrag then avatarDrag(self,...) end;HP.CompactLayout() end)
 local scroll=f.scroll:GetScript('OnVerticalScroll');f.scroll:SetScript('OnVerticalScroll',function(self,...) if scroll then scroll(self,...) end;HP.CompactTargets() end)
 local click=f.pause:GetScript('OnClick');f.pause:SetScript('OnClick',function(self,...) if click then click(self,...) end;f.pause.compactGlyph:SetText(HP.db.paused and '>' or '||||') end)
 local elapsed=0;local ticker=f:GetScript('OnUpdate');f:SetScript('OnUpdate',function(self,dt) if ticker then ticker(self,dt) end;elapsed=elapsed+dt;if elapsed>.3 then elapsed=0;HP.CompactTargets() end end)
 HP.CompactLayout()
end

local transparency=HP.ApplyTransparency
function HP.ApplyTransparency()
 transparency();if HP.frame and HP.frame.referenceBody then HP.frame.referenceBody:SetBackdropColor(.025,.019,.016,HP.db.transparent and .78 or 1);HP.frame.referenceHeaderFrame:SetBackdropColor(.025,.019,.016,HP.db.transparent and .86 or 1) end
end
