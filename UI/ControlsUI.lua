local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local function caption(parent,size)
 local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',size);t:SetTextColor(.94,.91,.8);return t
end
function HP.StyleSettingsPage(p)
 if not p or not HP.db then return end
 p:SetBackdrop({bgFile=WHITE});p:SetBackdropColor(.12,.065,.025,1);p:SetAlpha(1)
 local f=HP.frame
 if type(p.navigationButtons)=='table' then for name,b in pairs(p.navigationButtons) do
  local selected=p.page==name or name=='Chapters' and p.page=='Guide details';b.selected=selected
  b.bg:SetVertexColor(selected and .27 or .16,selected and .16 or .085,selected and .045 or .035,1);b.label:SetTextColor(1,selected and .92 or .83,selected and .42 or .30)
 end end
 local options={
 {p.questParty,'announceQuestParty',false,'Quest completion: party chat'},{p.questRaid,'announceQuestRaid',false,'Quest completion: raid chat'},
 {p.levelParty,'announceLevelParty',false,'Level gained: party chat'},{p.levelRaid,'announceLevelRaid',false,'Level gained: raid chat'},
 {p.autoWaypoint,'autoWaypoint',true,'Automatic waypoint'}, {p.previewToggle,'hideNPCPanel',true,'Target-hover NPC preview',true},
 {f.transparency,'transparent',false,'Guide transparency'}, {f.tips,'hideTips',true,'Extra hover hints',true},
 {f.arrowToggle,'arrowHidden',true,'Navigation arrow',true},{f.arrowLock,'arrowLocked',false,'Lock navigation arrow'},
 {f.routeLines,'hideRouteLines',true,'Dotted map route',true},{f.pinStyle,'pinCircles',false,'Circular map pins'},
 {p.strike,'noStrike',true,'Strike completed text',true},{p.itemBar,'questItemsHidden',true,'Quest-item bar',true},
 {p.classQuests,'includeClassQuests',true,'Include class quests'},{p.foreverQuests,'includeForeverQuests',true,'Include Forever quests'},
 {p.finished,'showCompleted',false,'Show completed steps'},{p.sound,'targetSound',false,'Visible target alerts'},
 {p.groupQuests,'includeGroupQuests',false,'Include group quests'},{p.raidQuests,'includeRaidQuests',false,'Include raid quests'},
 {p.markOnClick,'markOnClick',false,'Skull on target click'},{p.partyDone,'announceQuestDone',false,'Party quest announcements'},
 {p.partyLevel,'announceLevelTime',false,'Party level timing'},{p.fitStep,'autoFitStep',false,'Fit panel to current step'},
 {p.levelETA,'showLevelETA',false,'Time to next level'},{p.animatedTrail,'staticRouteTrail',true,'Animate dotted route',true},
 {p.minimapTrail,'hideMinimapTrail',true,'Minimap dotted route',true},{p.mapNumbers,'hideMapNumbers',true,'World-map numbers',true}}
 for _,entry in ipairs(options) do
  local b,key,default,title,inverse=unpack(entry)
  if type(b)=="table" or type(b)=="userdata" then
   local value=HP.db[key];local enabled
   if inverse then enabled=not value elseif default then enabled=value~=false else enabled=value==true end
   if type(b.switchTrack)~="table" and type(b.switchTrack)~="userdata" then
    local track=CreateFrame('Frame',nil,b,'BackdropTemplate');b.switchTrack=track;track:SetSize(72,22);track:SetPoint('RIGHT',-10,0)
    track:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});track:SetBackdropBorderColor(.65,.51,.22,1)
    track.thumb=track:CreateTexture(nil,'OVERLAY');track.thumb:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\ToggleThumb');track.thumb:SetSize(20,20)
    track.state=caption(track,9)
    local click=b:GetScript('OnClick');b:SetScript('OnClick',function(self,...) if click then click(self,...) end;HP.StyleSettingsPage(p) end)
   end
   local track=b.switchTrack;track.enabled=enabled;track:SetBackdropColor(enabled and .03 or .17,enabled and .34 or .12,enabled and .55 or .07,1)
   track.thumb:ClearAllPoints();track.thumb:SetPoint(enabled and 'RIGHT' or 'LEFT',track,enabled and 'RIGHT' or 'LEFT',enabled and -1 or 1,0)
   track.state:ClearAllPoints();track.state:SetPoint(enabled and 'LEFT' or 'RIGHT',track,enabled and 'LEFT' or 'RIGHT',enabled and 8 or -8,0);track.state:SetText(enabled and 'ON' or 'OFF')
   b.label:SetText(title);b.label:ClearAllPoints();b.label:SetPoint('LEFT',10,0);b.label:SetWidth(390);b.label:SetJustifyH('LEFT')
  end
 end
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local f=HP.frame;local p=HP.settings
 f.settingsGear:Hide()
 local strip=CreateFrame('Frame',nil,f,'BackdropTemplate');f.headerControls=strip;strip:SetSize(177,25);strip:SetPoint('TOPRIGHT',f,'TOPRIGHT',-27,-1);strip:SetBackdrop(nil)
 local settings=CreateFrame('Button',nil,strip,'BackdropTemplate');f.settingsButton=settings;settings:SetSize(78,24);settings:SetPoint('LEFT',0,0)
 settings.icon=settings:CreateTexture(nil,'ARTWORK');settings.icon:SetSize(18,18);settings.icon:SetPoint('LEFT',6,0);settings.label=caption(settings,10);settings.label:SetPoint('LEFT',28,0);settings.label:SetText('Settings');settings.icon:SetTexture('Interface\\Icons\\Trade_Engineering');settings:SetScript('OnClick',function() p.ShowPage('Options');p:Show();HP.StyleSettingsPage(p) end)
 settings:SetScript('OnEnter',function(self) if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_BOTTOM');GameTooltip:SetText('Settings');GameTooltip:Show() end end);settings:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
 f.rescan:SetParent(strip);f.rescan:ClearAllPoints();f.rescan:SetPoint('LEFT',strip,'LEFT',83,0);f.rescan:SetSize(28,24);f.rescan.icon:ClearAllPoints();f.rescan.icon:SetSize(22,22);f.rescan.icon:SetPoint('CENTER')
 f.pause:SetParent(strip);f.pause:ClearAllPoints();f.pause:SetPoint('RIGHT',strip,'RIGHT',0,0);f.pause:SetSize(61,24)
 for _,b in ipairs({settings,f.rescan,f.pause}) do
  b:SetBackdrop({bgFile=WHITE,edgeFile='Interface\\DialogFrame\\UI-DialogBox-Gold-Border',edgeSize=8,insets={left=3,right=3,top=3,bottom=3}});b:SetBackdropColor(.025,.08,.12,1);b:SetBackdropBorderColor(1,.78,.28,1);b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
 end
 f.setWaypoint:SetScript('OnClick',function() HP.db.autoWaypoint=HP.db.autoWaypoint==false;HP.manualWaypoint=nil;HP.manualWaypointQuestID=nil;HP.Refresh();HP.StyleSettingsPage(p) end)
 f.setWaypoint:SetScript('OnEnter',function(self) if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(HP.db.autoWaypoint~=false and 'Auto Waypoint: ON' or 'Auto Waypoint: OFF');GameTooltip:AddLine(HP.db.autoWaypoint~=false and 'Click to turn off the waypoint.' or 'Click to enable automatic waypoints.',.8,.9,1,true);GameTooltip:Show() end end)
 HP.ReferenceOrnament(p,18);p:SetBackdrop({bgFile=WHITE});p:SetBackdropColor(.12,.065,.025,1);p:SetAlpha(1)
 p.guideModeMenu:SetBackdropColor(.025,.05,.07,1)
 local titlebar=CreateFrame('Frame',nil,p,'BackdropTemplate');p.titleBar=titlebar;titlebar:SetPoint('TOPLEFT',7,-6);titlebar:SetPoint('TOPRIGHT',-7,-6);titlebar:SetHeight(31);titlebar:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Gold-Border',edgeSize=8});titlebar:SetBackdropColor(.35,.16,.045,1);titlebar:SetFrameLevel(p:GetFrameLevel()+1)
 p.windowTitle=caption(titlebar,14);p.windowTitle:SetPoint('CENTER');p.windowTitle:SetText("DUDE, WHERE'S MY DING?");p.windowTitle:SetTextColor(1,.82,.16)
 p.optionsClose=CreateFrame('Button',nil,titlebar,'UIPanelCloseButton');p.optionsClose:SetSize(28,28);p.optionsClose:SetPoint('RIGHT',0,0);p.optionsClose:SetScript('OnClick',function() p:Hide() end)
 HP.StyleSettingsPage(p)
end
local update=HP.UpdateModernPanel
function HP.UpdateModernPanel()
 update();local f=HP.frame;if not f or (type(f.headerControls)~='table' and type(f.headerControls)~='userdata') then return end
 if HP.Call(InCombatLockdown)==true then return end
 for _,row in ipairs(f.rows or {}) do
  if type(row.objectiveCheck)~="table" and type(row.objectiveCheck)~="userdata" then
   local box=CreateFrame('CheckButton',nil,row,'UICheckButtonTemplate');row.objectiveCheck=box;box:SetSize(22,22);box:SetPoint('TOPLEFT',8,-2);box:EnableMouse(false)
  end
  if row:IsShown() and row.objectiveRow then row.objectiveCheck:SetChecked(row.objectiveDone);row.objectiveCheck:Show() else row.objectiveCheck:Hide() end
 end
 if HP.settings:IsShown() then HP.StyleSettingsPage(HP.settings) end
end
