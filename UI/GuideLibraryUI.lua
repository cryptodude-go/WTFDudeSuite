local _,HP=...
local categories={{value='leveling',label='Leveling routes'},{value='zones',label='Race starters / zone guides'},{value='class',label='Class quests'},{value='dungeon',label='Dungeon quests'},{value='items',label='Item guides'}}
local function stateButton(control,title,enabled,y,click)
 local b=control(title,y,click);b.label:SetWidth(410)
 if not b.librarySwitch then
  local f=CreateFrame('Frame',nil,b,'BackdropTemplate');b.librarySwitch=f;f:SetSize(62,21);f:SetPoint('RIGHT',b,'RIGHT',-8,0);f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1})
  f.label=f:CreateFontString(nil,'OVERLAY');f.label:SetFont('Fonts\\FRIZQT__.TTF',10);f.label:SetAllPoints();f.label:SetJustifyH('CENTER')
 end
 b.librarySwitch:SetBackdropColor(enabled and .05 or .21,enabled and .50 or .12,enabled and .14 or .09,1);b.librarySwitch:SetBackdropBorderColor(.6,.5,.3,1);b.librarySwitch.label:SetText(enabled and 'ON' or 'OFF');b.librarySwitch:Show();return b
end
local function toggle(control,title,key,default,y,p)
 local enabled=HP.db[key];if enabled==nil then enabled=default end
 stateButton(control,title,enabled,y,function() HP.db[key]=not enabled;p.ShowPage(p.page);HP.Refresh() end)
end
local extra=HP.RenderExtraSettingsPage
function HP.RenderExtraSettingsPage(p,page,line,control,existing)
 if page=='Guide library' then
  local category=p.libraryCategory or 'leveling';local name=category
  for _,entry in ipairs(categories) do if entry.value==category then name=entry.label end end
  local chooser
  chooser=control(name..'   v',-51,function() HP.ChooseBookOption(chooser,categories,function(value) p.libraryCategory=value;p.ShowPage('Guide library') end) end)
  stateButton(control,'Show matching characters only',not p.libraryAllCharacters,-90,function() p.libraryAllCharacters=not p.libraryAllCharacters;p.ShowPage('Guide library') end)
  local query=(p.search:GetText() or ''):lower();local y=-139;local count=0
  for _,id in ipairs(HP.libraryOrder) do local g=HP.guideLibrary[id];local fits=HP.LibraryMatches(g)
   if g.category==category and (fits or p.libraryAllCharacters) and (query=='' or g.title:lower():find(query,1,true) or id:lower():find(query,1,true)) then
    count=count+1;control(g.title..(HP.db.libraryGuideID==id and '  |cff55ee77ACTIVE|r' or fits and '' or '  |cff999999OTHER CHARACTER|r'),y,function() p.libraryDetail=id;p.ShowPage('Guide entry') end)
    line((g.faction or 'Both factions')..' · '..#g.steps..' authored steps'..(g.classes and (' · '..table.concat(g.classes,', ')) or ''),11,0,y-30):SetHeight(24);y=y-62
   end
  end
  if count==0 then line('No matching guides. Clear the search or change the category.',13,0,y):SetHeight(55);y=y-70 end
  line('Ding v1.8.1 guides by moust4ki · GPL-3.0. Professions and reputation retain our guidebooks.',11,0,y-10):SetHeight(50)
  p.content:SetHeight(math.max(450,-y+80));return true
 elseif page=='Guide entry' then
  local g=HP.guideLibrary[p.libraryDetail];if not g then p.ShowPage('Guide library');return true end
  line(g.title,17,0,-47):SetHeight(45)
  line((g.faction or 'Both factions')..' · levels '..g.minLevel..'–'..g.maxLevel..' · '..#g.steps..' authored steps\n'..(HP.LibraryMatches(g) and 'Matches this character.' or 'For another race, class or faction.'),12,0,-99):SetHeight(55)
  if HP.LibraryMatches(g) then control('Load / resume this guide',-167,function()
   if g.category=='dungeon' then HP.db.includeGroupQuests=true end
   if g.category=='class' then HP.db.includeClassQuests=true end
   HP.SelectLibraryGuide(g.id);p:Hide()
  end) end
  control('Back to guide library',-208,function() p.ShowPage('Guide library') end)
  line('Authored routes use Normal mode, including Forever quests when enabled. Classic Speedrun remains a separate guide mode. Travel, trainer and service instructions can require manual confirmation with Next.',12,0,-258):SetHeight(90)
  if g.next then local next=HP.guideLibrary[g.next];line('Next section: '..(next and next.title or g.next),12,0,-359):SetHeight(40) end
  line('Source: Ding! v1.8.1 by moust4ki. Adapted with GPL-3.0 attribution; no Ding addon dependency.',11,0,-416):SetHeight(58)
  p.content:SetHeight(510);return true
 elseif page=='Library options' then
  toggle(control,'Continue to the next matching guide section','libraryAutoNext',true,-63,p)
  toggle(control,'Include optional death skips and cleanup steps','libraryAdvancedSteps',false,-109,p)
  control('Use our all-zone quest planner',-153,function() HP.db.libraryGuideID=nil;HP.ChooseGuideBook('leveling');HP.UseGuide();p.ShowPage('Library options') end)
  control('Browse authored guide sections',-197,function() p.ShowPage('Guide library') end)
  line('Authored guide progress is saved separately from your existing zone progress. Race, class, faction and step conditions filter each guide. Quest steps advance from live quest state; unverified service/travel actions wait for confirmation.',12,0,-251):SetHeight(112)
  p.content:SetHeight(450);return true
 elseif page=='Quest assistance' then
  toggle(control,'Accept quests offered for the active guide','autoAcceptQuests',false,-65,p)
  toggle(control,'Turn in guide quests with no reward choice','autoTurnInQuests',false,-109,p)
  line('Both options start OFF. Talk to the NPC yourself. Hold Shift to suspend assistance. Reward choices, buying, selling, talent allocation, banking, abandonment and item destruction stay manual.',12,0,-170):SetHeight(110)
  p.content:SetHeight(450);return true
 elseif page=='Keybinds' then
  line('Configure these actions in WoW’s Key Bindings under WTF! DUDE SUITE:',13,0,-55):SetHeight(65)
  local y=-129
  for _,entry in ipairs({{'Next / confirm step','DWMG_DING_NEXT'},{'Previous step','DWMG_DING_PREVIOUS'},{'Pause / resume','DWMG_DING_PAUSE'},{'Show / hide guide','DWMG_DING_TOGGLE'},{'Open settings','DWMG_DING_SETTINGS'}}) do
   local key=HP.Call(GetBindingKey,entry[2]);line(entry[1]..'   '..(key or 'Not bound'),13,0,y):SetHeight(30);y=y-42
  end
  line('Keyboard and mouse controls are supported. Ding’s controller navigation is not included.',11,0,y-14):SetHeight(50);p.content:SetHeight(460);return true
 end
 return extra(p,page,line,control,existing)
end
