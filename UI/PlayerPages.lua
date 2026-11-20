local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local function frame(value) return type(value)=='table' or type(value)=='userdata' end
local function cash(n)
 local sign=n<0 and '-' or '';n=math.abs(n);return sign..string.format('%dg %ds %dc',math.floor(n/10000),math.floor(n/100)%100,math.floor(n)%100)
end
HP.ActivityMoneyText=cash
function HP.ModeCoverage()
 local normal,speed,new={}, {},0
 for _,id in ipairs(HP.guideOrder) do for _,step in ipairs(HP.routes[id].steps) do if step.questID then normal[step.questID]=true end end end
 for _,chapter in ipairs(HP.chapterList) do local route=HP.routes[chapter.id];if route then for _,step in ipairs(route.steps) do
  local q=HP.questData[step.questID]
  if q and HP.SpeedQuestIncluded(step,route) and not (q.groupRecommended or q.repeatable or q.questType==21) then speed[step.questID]=true end
 end end end
 local n,s=0,0;for id in pairs(normal) do n=n+1;if HP.questData[id] and HP.questData[id].newForever then new=new+1 end end;for _ in pairs(speed) do s=s+1 end
 return n,s,new
end
function HP.RenderExtraSettingsPage(p,page,line,control,existing)
 if page=='Guide Mode' then
  local normal,speed,new=HP.ModeCoverage()
  line('Choose how your leveling guide plans the next quest.',12,0,-40)
  existing(p.guideMode,-76)
  line('Normal / all indexed zone quests',17,0,-126)
  line(normal..' distinct indexed quests across '..#HP.guideOrder..' zone guides; '..new..' Forever quests.',12,0,-158):SetHeight(44)
  line('Rescans your current quest log and completed history on login, reload and guide changes. Continues accepted zone quests with objectives and turn-in waypoints. Race, class, group and raid filters still apply.',12,0,-207):SetHeight(80)
  line('Speedrun planner (experimental)',17,0,-309)
  line(speed..' distinct eligible quests across '..#HP.chapterList..' route chapters before character and difficulty filters.',12,0,-341):SetHeight(44)
  line('Prioritizes shorter travel and solo objectives. Suggests abandoning accepted quests excluded from the route, and continues after you abandon them. This planner has not been benchmarked as the fastest 1–60 route.',12,0,-390):SetHeight(85)
  local total,class,newZone,pending=0,0,0,0;if HP.route then total,class,newZone,pending=HP.GuideStats(HP.route) end
  line('Current zone: '..(HP.route and HP.route.title or 'None'),14,0,-500)
  line((total or 0)..' indexed quests; '..(class or 0)..' class; '..(newZone or 0)..' Forever; '..(pending or 0)..' awaiting coordinates.',12,0,-534):SetHeight(44)
  p.guideMode.label:SetText('Guide mode: '..(HP.db.guideStyle=='speed' and 'Speedrun (experimental)' or 'Normal / all zone quests')..'  v')
  p.content:SetHeight(615);return true
 elseif page=='Announcements' then
  HP.InitAnnouncements()
  line('Quest objectives finished / ready for turn-in',14,0,-44)
  existing(p.questParty,-77);existing(p.questRaid,-113)
  line('Level gained, including time spent on that level',14,0,-159)
  existing(p.levelParty,-192);existing(p.levelRaid,-228)
  line('Customize your messages',16,0,-282)
  line('Tokens: {quest}, {level}, {time}, {player}. Time is addon-tracked play time.',11,0,-315):SetHeight(42)
  line('Quest completion message',12,0,-364)
  p.questEditor:ClearAllPoints();p.questEditor:SetPoint('TOPLEFT',8,-392);p.questEditor:SetText(HP.db.questAnnouncement);p.questEditor:Show()
  line('Level-up message',12,0,-438)
  p.levelEditor:ClearAllPoints();p.levelEditor:SetPoint('TOPLEFT',8,-466);p.levelEditor:SetText(HP.db.levelAnnouncement);p.levelEditor:Show()
  control('Save messages',-511,function()
   local quest=(p.questEditor:GetText() or ''):gsub('[\r\n]',' ');local level=(p.levelEditor:GetText() or ''):gsub('[\r\n]',' ')
   HP.db.questAnnouncement=quest~='' and quest or HP.DefaultQuestMessage;HP.db.levelAnnouncement=level~='' and level or HP.DefaultLevelMessage
   p.messageSaved=true;p.ShowPage('Announcements')
  end,247)
  control('Restore funny defaults',-511,function() HP.db.questAnnouncement=HP.DefaultQuestMessage;HP.db.levelAnnouncement=HP.DefaultLevelMessage;p.messageSaved=true;p.ShowPage('Announcements') end,247,263)
  line(p.messageSaved and 'Messages saved for this character.' or 'Messages send only when their destination toggle is ON.',11,0,-549):SetHeight(42)
  line('Quest example: '..HP.AnnouncementText('quest',{quest='Lazy Peons'}),11,0,-594):SetHeight(50)
  line('Level example: '..HP.AnnouncementText('level',{level=10,time='18m 42s'}),11,0,-651):SetHeight(50)
  p.content:SetHeight(728);return true

 end
 return false
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local p=HP.settings;p.messageEditors={}
 local function toggle(field,key,title)
  local b=CreateFrame('Button',nil,p.content,'BackdropTemplate');p[field]=b;b:SetSize(510,28);b:SetBackdrop({bgFile=WHITE,edgeFile='Interface\\DialogFrame\\UI-DialogBox-Gold-Border',edgeSize=8});b:SetBackdropColor(.16,.085,.035,1)
  b.label=b:CreateFontString(nil,'OVERLAY');b.label:SetFont('Fonts\\FRIZQT__.TTF',12);b.label:SetTextColor(1,.83,.3);b.label:SetText(title);b.label:SetPoint('LEFT',10,0)
  b:SetScript('OnClick',function() HP.db[key]=not HP.db[key];HP.StyleSettingsPage(p) end);p.controls[#p.controls+1]=b;b:Hide()
 end
 toggle('questParty','announceQuestParty','Quest completion: party chat');toggle('questRaid','announceQuestRaid','Quest completion: raid chat');toggle('levelParty','announceLevelParty','Level gained: party chat');toggle('levelRaid','announceLevelRaid','Level gained: raid chat')
 local function editor(field)
  local b=CreateFrame('EditBox',nil,p.content,'InputBoxTemplate');p[field]=b;b:SetSize(493,29);b:SetAutoFocus(false);b:SetMaxLetters(220);b:SetScript('OnEscapePressed',function(self) self:ClearFocus() end);b:SetScript('OnEnterPressed',function(self) self:ClearFocus() end);b:Hide();p.messageEditors[#p.messageEditors+1]=b
 end
 editor('questEditor');editor('levelEditor');HP.StyleSettingsPage(p)
end
