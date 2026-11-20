local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local tabs={
 {title='Guide',pages={{'Guide library','Guide library'},{'Current','Current guide'},{'Leveling','Leveling'},{'Chapters','All zone quests'},{'Professions','Professions'},{'Gathering','Gathering'},{'Reputation','Reputation'}}},
 {title='Route',pages={{'Library options','Guide progression'},{'Guide Mode','Normal / Speedrun'},{'Options','Quest filters & targets'}}},
 {title='Automation',pages={{'Quest assistance','Quest assistance'},{'Announcements','Chat announcements'}}},
 {title='Arrow & maps',pages={{'Navigation','Waypoint arrow'},{'Map','Map & minimap lines'}}},
 {title='Keybinds',pages={{'Keybinds','Keyboard shortcuts'}}},
 {title='Appearance',pages={{'Display','Tracker appearance'},{'Home','About this addon'}}}
}
HP.intentSettingsTabs=tabs
local function button(parent,title)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');b:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});b:SetBackdropColor(.10,.085,.065,1);b:SetBackdropBorderColor(.39,.32,.22,1)
 b.label=b:CreateFontString(nil,'OVERLAY');b.label:SetFont('Fonts\\FRIZQT__.TTF',12);b.label:SetAllPoints();b.label:SetJustifyH('CENTER');b.label:SetText(title)
 b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD');return b
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local p=HP.settings;p:SetSize(920,660)
 if type(p.GetRegions)=='function' then for _,r in ipairs({p:GetRegions()}) do if r.Hide then r:Hide() end end end
 p.intentBackground=p:CreateTexture(nil,'BACKGROUND');p.intentBackground:SetAllPoints();p.intentBackground:SetTexture(WHITE);p.intentBackground:SetVertexColor(.035,.031,.027,1)
 p:SetBackdropColor(.035,.031,.027,1);p:SetBackdropBorderColor(.62,.45,.23,1)
 local title=p:CreateFontString(nil,'OVERLAY');title:SetFont('Fonts\\FRIZQT__.TTF',18);title:SetPoint('TOPLEFT',p,'TOPLEFT',20,-16);title:SetText("WTF! DUDE SUITE");title:SetTextColor(1,.84,.46)
 if p.titleBar then p.titleBar:Hide() end
 local close=button(p,'X');close:SetSize(27,25);close:SetPoint('TOPRIGHT',p,'TOPRIGHT',-12,-11);close:SetScript('OnClick',function() p:Hide() end)
 local footer=p:CreateFontString(nil,'OVERLAY');footer:SetFont('Fonts\\FRIZQT__.TTF',10);footer:SetPoint('BOTTOMRIGHT',p,'BOTTOMRIGHT',-18,13);footer:SetText('v'..HP.GetDingVersion());footer:SetTextColor(.7,.65,.55)
 p.scroll:ClearAllPoints();p.scroll:SetPoint('TOPLEFT',p,'TOPLEFT',220,-139);p.scroll:SetPoint('BOTTOMRIGHT',p,'BOTTOMRIGHT',-28,43);p.content:SetWidth(642)
 p.search:ClearAllPoints();p.search:SetPoint('TOPLEFT',p,'TOPLEFT',231,-99);p.search:SetWidth(620)
 if p.versionText then p.versionText:Hide() end
 p.intentTabButtons={};p.intentNavButtons={}
 local pageTabs={};for index,tab in ipairs(tabs) do for _,entry in ipairs(tab.pages) do pageTabs[entry[1]]=index end end
 pageTabs['Guide entry']=1;pageTabs['Guide details']=1;pageTabs['Recent']=1
 local function layout(page)
  local index=pageTabs[page] or p.intentTab or 1;p.intentTab=index
  for _,b in pairs(p.navigationButtons) do b:Hide() end
  for i,b in ipairs(p.intentTabButtons) do b:SetBackdropColor(i==index and .28 or .10,i==index and .15 or .085,i==index and .06 or .065,1);b:SetBackdropBorderColor(i==index and .95 or .39,i==index and .67 or .32,i==index and .25 or .22,1) end
  for _,b in ipairs(p.intentNavButtons) do b:Hide() end
  for i,entry in ipairs(tabs[index].pages) do
   local b=p.intentNavButtons[i]
   if not b then b=button(p,'');b:SetSize(188,33);b:SetPoint('TOPLEFT',p,'TOPLEFT',14,-104-(i-1)*40);p.intentNavButtons[i]=b end
   b.label:SetText(entry[2]);local target=entry[1];b:SetScript('OnClick',function() p.ShowPage(target) end);b:SetBackdropBorderColor(page==target and .95 or .39,page==target and .67 or .32,page==target and .25 or .22,1);b:Show()
  end
 end
 local show=p.ShowPage
 p.ShowPage=function(page) for _,b in ipairs(p.pageControls) do if b.librarySwitch then b.librarySwitch:Hide() end end;show(page);layout(page) end
 for i,tab in ipairs(tabs) do local b=button(p,tab.title);p.intentTabButtons[i]=b;b:SetSize(146,33);b:SetPoint('TOPLEFT',p,'TOPLEFT',15+(i-1)*149,-52);local page=tab.pages[1][1];b:SetScript('OnClick',function() p.ShowPage(page) end) end
 if p.searchHint then p.searchHint:SetText('Search guides / zones') end
 p.search:SetScript('OnTextChanged',function(self,user) if p.searchHint then p.searchHint:SetShown(self:GetText()=='') end;if not user then return end;p.ShowPage((p.page=='Chapters' or p.page=='Guide details') and 'Chapters' or 'Guide library') end)
 p.ShowPage('Guide library')
 local slash=SlashCmdList.DUDEWHERESMYDING
 SlashCmdList.DUDEWHERESMYDING=function(input)
  if input=='library' then p.ShowPage('Guide library');p:Show();return end
  if input=='planner' then HP.db.libraryGuideID=nil;HP.ChooseGuideBook('leveling');HP.UseGuide();return end
  return slash(input)
 end
end
function HP.BindingAction(action)
 if not HP.db or not HP.frame then return end
 if action=='next' then HP.Move(1) elseif action=='previous' then HP.Move(-1)
 elseif action=='settings' then HP.settings.ShowPage('Guide library');HP.settings:SetShown(not HP.settings:IsShown())
 elseif action=='pause' then HP.db.paused=not HP.db.paused;HP.Refresh()
 elseif action=='toggle' then HP.db.hidden=not HP.db.hidden;HP.Refresh() end
end
BINDING_HEADER_DUDEWHERESMYDING="WTF! DUDE SUITE"
for key,label in pairs({NEXT='Next / confirm step',PREVIOUS='Previous step',PAUSE='Pause / resume',TOGGLE='Show / hide guide',SETTINGS='Open settings'}) do _G['BINDING_NAME_DWMG_DING_'..key]=label end
_G.DudeDingBinding=HP.BindingAction
