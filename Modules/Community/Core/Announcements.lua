local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(30,'community',function(...)
-- Editable announcement pools; exactly one line per eligible event/channel.
local _,HP=...
local D=HP.Native;local C,UI=D.Config,D.UI
local A={last={},order={}};HP.Announcements=A
local defaults={
 quest={
  'Quest complete: {quest}. Another win with WTF! DUDE!',
  '{quest}: done. WTF! DUDE made the to-do list shorter!',
  'Objectives crushed: {quest}. Powered by WTF! DUDE!',
  'One less problem in Azeroth: {quest}. WTF! DUDE!',
  '{quest} is ready to hand in. WTF! DUDE, where is my reward?',
  'Mission accomplished: {quest}. Another step with WTF! DUDE!',
  'That is {quest} sorted. WTF! DUDE keeps the adventure moving!',
  'Azeroth asked; I delivered. {quest} complete with WTF! DUDE!',
  '{quest}: checked off. WTF! DUDE says it is reward time!',
  'Quest goals finished: {quest}. Onward with WTF! DUDE!'
 },
 level={
  'Level {level}! Climbing Azeroth with WTF! DUDE!',
  'Level {level} in {time}. WTF! DUDE, that XP bar never stood a chance!',
  'New level unlocked: {level}. Adventure assisted by WTF! DUDE!',
  '{player} reached level {level}! Another milestone with WTF! DUDE!',
  'Level {level}! Bigger adventures, same WTF! DUDE!',
  'The XP bar surrendered: level {level}, with WTF! DUDE!',
  'Ding! Level {level} in {time}. Thanks for the directions, WTF! DUDE!',
  'One level stronger: {level}. Rolling onward with WTF! DUDE!',
  'Level {level} achieved! WTF! DUDE kept me on the trail!',
  'Fresh level, fresh trouble: {level}! Leveling with WTF! DUDE!'
 }
};A.defaults=defaults
function A:DB()
 local db=HP.db;db.announcementPools=db.announcementPools or {};local pools=db.announcementPools
 for _,kind in ipairs({'quest','level'})do
  pools[kind]=pools[kind]or {random=true,texts={}};local p=pools[kind];p.texts=p.texts or {}
  if p.random==nil then p.random=true end
  if not p.migrated then
   for i=1,10 do if p.texts[i]==nil then p.texts[i]=defaults[kind][i]end end
   local old=db[kind..'Announcement'];local original=kind=='quest'and HP.DefaultQuestMessage or HP.DefaultLevelMessage
   if type(old)=='string'and old~=''and old~=original then p.texts[1]=old end
   p.migrated=true
  end
 end
 return pools
end
function A:Template(kind)
 local p=self:DB()[kind];local choices={}
 for i=1,10 do if type(p.texts[i])=='string'and p.texts[i]:match('%S')then choices[#choices+1]=i end end
 if #choices==0 then return end
 local selected=choices[1]
 if p.random and #choices>1 then
  local filtered={};for _,i in ipairs(choices)do if i~=self.last[kind]then filtered[#filtered+1]=i end end
  selected=filtered[math.random(#filtered)]
 end
 self.last[kind]=selected;return p.texts[selected]
end
function HP.AnnouncementText(kind,values)
 local template=A:Template(kind);if not template then return end
 values=values or {};local player=HP.Call(UnitName,'player')or 'Adventurer'
 local result=template:gsub('{(%w+)}',function(k)local v=k=='player'and player or values[k];return HP.Public(v)and tostring(v or '{'..k..'}')or '?'end):gsub('[\r\n]',' '):gsub('|','')
 if #result>240 then result=result:sub(1,240):gsub('[\128-\191]*$',''):gsub('[\192-\244]$','')end
 return result
end
function HP.Announce(kind,values)
 if not HP.Suite:On('community')or not HP.db or(kind~='quest'and kind~='level')then return false end
 HP.InitAnnouncements();values=values or {};local suffix=kind=='quest'and 'Quest'or 'Level';local channel
 if HP.Call(IsInRaid)==true then if HP.db['announce'..suffix..'Raid']then channel='RAID'end
 elseif HP.Call(IsInGroup)==true and HP.db['announce'..suffix..'Party']then
  channel=LE_PARTY_CATEGORY_INSTANCE and HP.Call(IsInGroup,LE_PARTY_CATEGORY_INSTANCE)and 'INSTANCE_CHAT'or 'PARTY'
 end
 if not channel or type(SendChatMessage)~='function'then return false end
 local key,level
 if kind=='level'and HP.Public(values.level)and type(values.level)=='number'then
  level=values.level;if level<=(HP.db.announcementLastLevel or 0)then return false end;key='level:'..level
 elseif kind=='quest'then
  local q=values.questID or values.quest;if not HP.Public(q)then return false end;key='quest:'..tostring(q)
 else return false end
 local now=HP.Call(GetTime)or 0;local last=A.sent and A.sent[key]
 if last and now-last<10 then return false end
 local message=HP.AnnouncementText(kind,values);if not message then return false end
 local ok,result=pcall(SendChatMessage,message,channel);if not ok or result==false then return false end
 A.sent=A.sent or {};A.sent[key]=now;A.order[#A.order+1]={key=key,at=now}
 while #A.order>128 do local old=table.remove(A.order,1);if A.sent[old.key]==old.at then A.sent[old.key]=nil end end
 if level then HP.db.announcementLastLevel=level end
 return true
end
function A:Edit(kind,index)
 local f=self.editor
 if not f then
  f=CreateFrame('Frame',nil,UIParent);self.editor=f;f:SetSize(590,165);f:SetPoint('CENTER');f:SetFrameStrata('DIALOG');f:EnableMouse(true);UI.Window(f,'dialog')
  f.title=UI.Text(f,'semibold',14,UI.C.text);f.title:SetPoint('TOPLEFT',16,-15)
  f.edit=CreateFrame('EditBox',nil,f,'InputBoxTemplate');f.edit:SetSize(550,32);f.edit:SetPoint('TOPLEFT',20,-48);f.edit:SetAutoFocus(false);f.edit:SetMaxLetters(240)
  local hint=UI.Text(f,'regular',11,UI.C.secondary);hint:SetPoint('TOPLEFT',16,-95);hint:SetWidth(550);hint:SetText('Enter: save · Escape: cancel · Blank: exclude this message\nTokens: {quest}, {level}, {time}, {player}')
  f.edit:SetScript('OnEnterPressed',function(e)A:DB()[f.kind].texts[f.index]=e:GetText();e:ClearFocus();f:Hide();if C.page then C:OpenPage(C.page.def)end end)
  f.edit:SetScript('OnEscapePressed',function(e)e:ClearFocus();f:Hide()end)
 end
 f.kind=kind;f.index=index;f.title:SetText((kind=='quest'and 'Quest'or 'Level-up')..' message '..index);f.edit:SetText(self:DB()[kind].texts[index]or '');f:Show();f.edit:SetFocus();f.edit:HighlightText()
end
local pages={};A.pages=pages
for _,name in ipairs({'quest','level'})do
 local kind=name;local page={cache=true,key='wtf-messages-'..kind,title=kind=='quest'and 'Quest messages · 10 editable choices'or 'Level-up messages · 10 editable choices'};pages[kind]=page
 page.build=function(canvas,width)
  local pool=A:DB()[kind];local rows={UI.CheckRow(canvas,C,{label='Choose a random message',desc='Off: use the first nonblank message. Blank entries are excluded.',default=true,get=function()return pool.random end,set=function(v)pool.random=v end},width)}
  for i=1,10 do local index=i;rows[#rows+1]=UI.ButtonRow(canvas,C,{label='Message '..index,desc=function()return pool.texts[index]~=''and pool.texts[index]or '(excluded)'end,button='Edit',run=function()A:Edit(kind,index)end},width)end
  rows[#rows+1]=UI.ButtonRow(canvas,C,{label='Restore these 10 default messages',button='Reset',confirm='Replace your edited messages?',run=function()for i=1,10 do pool.texts[i]=defaults[kind][i]end;C:OpenPage(page)end},width)
  return rows
 end
end
local build=C.TABS[C.TAB.community].build
C.TABS[C.TAB.community].build=function(canvas,width)
 local rows=build(canvas,width)
 for i=#rows,1,-1 do if rows[i].opts and(rows[i].opts.label=='Quest message'or rows[i].opts.label=='Level message')then rows[i]:Hide();table.remove(rows,i)end end
 for _,name in ipairs({'quest','level'})do local kind=name;rows[#rows+1]=UI.PageRow(canvas,C,{label=kind=='quest'and 'Quest messages · 10 editable choices'or 'Level-up messages · 10 editable choices',open=function()C:OpenPage(pages[kind])end},width)end
 return rows
end
D:On('PLAYER_LOGIN',function()A:DB()end)

end)
