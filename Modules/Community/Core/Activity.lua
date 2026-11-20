local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(5,'community',function(...)
local _,HP=...
local function number(v) return HP.Public(v) and type(v)=='number' and v or nil end
local function clock() return number(HP.Call(GetServerTime)) or number(HP.Call(time)) or number(HP.Call(GetTime)) or 0 end
HP.ActivityNow=clock
local function multi(fn,...)
 if type(fn)~='function' then return end;local result={pcall(fn,...)};if not result[1] then return end
 for i=2,11 do if not HP.Public(result[i]) then result[i]=nil end end;return unpack(result,2,11)
end
local function day(t) return HP.Call(date,'%Y-%m-%d',t) or tostring(math.floor(t/86400)) end
local function append(list,value,limit) list[#list+1]=value;while #list>limit do table.remove(list,1) end end
HP.DefaultQuestMessage='Done: {quest}. Another chore bites the dust!'
HP.DefaultLevelMessage='Level {level} in {time}. My XP bar finally gave up.'
function HP.InitAnnouncements()
 local d=HP.db
 for _,kind in ipairs({'Quest','Level'}) do
  local old;if kind=='Quest' then old=d.announceQuestDone else old=d.announceLevelTime end
  local party='announce'..kind..'Party';local raid='announce'..kind..'Raid'
  if d[party]==nil then d[party]=old~=false end;if d[raid]==nil then d[raid]=false end
 end
 d.questAnnouncement=d.questAnnouncement or HP.DefaultQuestMessage;d.levelAnnouncement=d.levelAnnouncement or HP.DefaultLevelMessage
 if d.levelAnnouncement=='Ding! Level {level} in {time}. My XP bar finally gave up.' then d.levelAnnouncement=HP.DefaultLevelMessage end
end
function HP.AnnouncementText(kind,values)
 local template=kind=='quest' and HP.db.questAnnouncement or HP.db.levelAnnouncement
 values=values or {};values.player=HP.Call(UnitName,'player') or 'Adventurer'
 local result=template:gsub('{(%w+)}',function(key) return tostring(values[key] or '{'..key..'}') end):gsub('[\r\n]',' '):gsub('|','')
 if #result>240 then result=result:sub(1,240):gsub('[\128-\191]*$',''):gsub('[\192-\244]$','') end
 return result
end
function HP.Announce(kind,values)
 if HP.Suite and not HP.Suite:On('community') then return end
 HP.InitAnnouncements();local suffix=kind=='quest' and 'Quest' or 'Level';local raid=HP.Call(IsInRaid)==true
 if raid and HP.db['announce'..suffix..'Raid'] then HP.Call(SendChatMessage,HP.AnnouncementText(kind,values),'RAID')
 elseif not raid and HP.Call(IsInGroup)==true and HP.db['announce'..suffix..'Party'] then
  local channel=LE_PARTY_CATEGORY_INSTANCE and HP.Call(IsInGroup,LE_PARTY_CATEGORY_INSTANCE) and 'INSTANCE_CHAT' or 'PARTY'
  HP.Call(SendChatMessage,HP.AnnouncementText(kind,values),channel)
 end
end
local function totals() return {xp=0,income=0,spent=0,honor=0,auction=0,tradeIn=0,tradeOut=0,currencies={}} end
function HP.ActivityInit()
 local d=HP.db;d.activity=d.activity or {started=clock(),total=totals(),runs={},entries={},serial=0}
 local a=d.activity;local today=day(clock());if not a.daily or a.daily.day~=today then a.daily=totals();a.daily.day=today end
 return a
end
local function add(key,value)
 if not number(value) or value<=0 then return end
 local a=HP.ActivityInit();a.total[key]=(a.total[key] or 0)+value;a.daily[key]=(a.daily[key] or 0)+value
 if a.current then a.current[key]=(a.current[key] or 0)+value end
end
function HP.ActivityXP(newLevel)
 local v=HP.activityRuntime;if not v then return end
 local xp=number(HP.Call(UnitXP,'player'));local cap=number(HP.Call(UnitXPMax,'player'));local level=number(newLevel) or number(HP.Call(UnitLevel,'player')) or HP.character.level
 if not xp or not cap or not level then return end
 if v.level and level<v.level then return end -- XP event can precede the level API update.
 if v.xp then
  if level>v.level then
   local current=number(HP.Call(UnitLevel,'player'))==level and xp or 0
   add('xp',math.max(0,(v.cap or 0)-v.xp)+current);xp=current
  else add('xp',math.max(0,xp-v.xp)) end
 end
 v.xp=xp;v.cap=cap;v.level=level
end
function HP.ActivityMoney()
 local v=HP.activityRuntime;local value=number(HP.Call(GetMoney));if not v or not value then return end
 if v.money then
  local delta=value-v.money;add(delta>=0 and 'income' or 'spent',math.abs(delta))
  if delta>0 and v.mail and clock()-v.mail.at<20 then
   local remaining=delta
   while v.mail and v.mail.items[1] and remaining>=v.mail.items[1] do local amount=table.remove(v.mail.items,1);add('auction',amount);remaining=remaining-amount;v.mail.amount=v.mail.amount-amount end
   if v.mail.amount<=0 then v.mail=nil end
  end
 end
 v.money=value
end
function HP.ActivityCurrency(id,quantity,change)
 id=number(id);quantity=number(quantity);change=number(change);if not id or not quantity then return end
 local v=HP.activityRuntime;local old=v.currencyBalances[id];v.currencyBalances[id]=quantity
 change=old~=nil and math.max(0,quantity-old) or math.max(0,change or 0)
 local a=HP.ActivityInit();local info=HP.Call(C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo,id);local name=type(info)=='table' and info.name or 'Currency '..id
 for _,bucket in ipairs({a.total,a.daily}) do
  local count=0;for _ in pairs(bucket.currencies) do count=count+1 end
  if bucket.currencies[id] or count<100 then local c=bucket.currencies[id] or {name=name,gained=0};bucket.currencies[id]=c;c.gained=c.gained+change;c.balance=quantity;c.name=name end
 end
end
function HP.ScanCurrencies(seed)
 local api=C_CurrencyInfo;local size=number(HP.Call(api and api.GetCurrencyListSize or GetCurrencyListSize)) or 0
 for index=1,math.min(size,150) do
  local info=HP.Call(api and api.GetCurrencyListInfo,index);local id,name,balance,header
  if type(info)=='table' then id=number(info.currencyID);name=info.name;balance=number(info.quantity);header=info.isHeader
  else local n,h,_,_,_,count=multi(GetCurrencyListInfo,index);name=n;header=h;balance=number(count) end
  local link=HP.Call(api and api.GetCurrencyListLink or GetCurrencyListLink,index);id=id or type(link)=='string' and tonumber(link:match('currency:(%d+)'))
  if id and not header and balance then
   local old=HP.activityRuntime.currencyBalances[id];HP.activityRuntime.currencyBalances[id]=balance
   local a=HP.ActivityInit();for _,bucket in ipairs({a.total,a.daily}) do
    local c=bucket.currencies[id] or {name=name or 'Currency '..id,gained=0};bucket.currencies[id]=c;c.balance=balance
    if not seed and old and balance>old then c.gained=c.gained+balance-old end
   end
  end
 end
end
function HP.ActivityHonor()
 local v=HP.activityRuntime;if not v then return end
 local value=number(HP.Call(UnitHonor,'player'));if not value then local _,honor=HP.Call(GetPVPSessionStats);value=number(honor) end
 if value then if v.honor and value>=v.honor then add('honor',value-v.honor) end;v.honor=value;v.honorAvailable=true end
end
function HP.DungeonCounts()
 local a=HP.ActivityInit();local now=clock();local hour,window,today=0,0,0;local firstHour,firstDay
 for i=#a.entries,1,-1 do
  local t=a.entries[i];if now-t>=86400 then table.remove(a.entries,i) else
   window=window+1;if not firstDay or t<firstDay then firstDay=t end
   if now-t<3600 then hour=hour+1;if not firstHour or t<firstHour then firstHour=t end end
  end
 end
 today=a.daily.runs or 0
 return hour,window,today,firstHour and math.max(0,firstHour+3600-now) or 0,firstDay and math.max(0,firstDay+86400-now) or 0
end
function HP.EndDungeon(completed)
 local a=HP.ActivityInit();local run=a.current;if not run then return end
 if completed and not run.completed then a.daily.completedRuns=(a.daily.completedRuns or 0)+1 end
 run.ended=clock();run.completed=completed==true;run.status=completed and 'Complete' or 'Visit ended';a.last=run;a.current=nil
end
function HP.StartDungeon(name,map,difficulty)
 local a=HP.ActivityInit();a.serial=a.serial+1
 local run={id=a.serial,name=name,mapID=map,difficulty=difficulty,started=clock(),status='In progress',xp=0,income=0,spent=0,honor=0,bosses={},loot={},rolls={}}
 a.daily.runs=(a.daily.runs or 0)+1;append(a.runs,run,50);append(a.entries,run.started,200);a.current=run;return run
end
function HP.CheckDungeon()
 local a=HP.ActivityInit();local name,kind,difficulty,_,_,_,_,map=multi(GetInstanceInfo)
 if kind~='party' and kind~='raid' then
  if a.current then a.current.left=clock();a.current.status='Outside - run retained';a.last=a.current;a.current=nil end
  HP.activityRuntime.inside=false;return
 end
 if a.current and a.current.mapID==map then a.current.status=a.current.completed and 'Complete - still inside' or 'In progress';a.current.left=nil;return end
 if a.current then HP.EndDungeon(false) end
 local old=a.last
 if old and not HP.activityRuntime.reset and old.mapID==map and clock()-(old.left or old.started)<3600 then a.current=old;old.status=old.completed and 'Complete - reentered' or 'In progress';old.left=nil
 else HP.StartDungeon(name or 'Dungeon',map,difficulty) end
 HP.activityRuntime.reset=false;HP.activityRuntime.inside=true
end
function HP.DungeonSource(guid)
 if type(guid)~='string' then return end
 local prefix,id=guid:match('^(Creature%-[^-]+%-[^-]+%-[^-]+%-[^-]+)%-(%d+)');local a=HP.ActivityInit();local run=a.current
 if run and prefix then
  if run.instanceKey and run.instanceKey~=prefix then
   HP.EndDungeon(false);run=HP.StartDungeon(run.name,run.mapID,run.difficulty)
  end
  run.instanceKey=prefix
 end
 return tonumber(id)
end
function HP.RecordDungeonLoot()
 local run=HP.ActivityInit().current;if not run then return end
 for slot=1,(number(HP.Call(GetNumLootItems)) or 0) do
  local link=HP.Call(GetLootSlotLink,slot);local guid=HP.Call(GetLootSourceInfo,slot);local npc=HP.DungeonSource(guid);run=HP.ActivityInit().current
  if type(link)=='string' then
   local signature=tostring(guid)..':'..slot..':'..link;local found=false
   for _,drop in ipairs(run.loot) do if drop.signature==signature then found=true;break end end
   if not found then
    local _,_,quantity=HP.Call(GetLootSlotInfo,slot);local data=npc and HP.npcData[npc]
    append(run.loot,{link=link,quantity=number(quantity) or 1,source=data and data.name or npc and 'NPC '..npc or 'Unreported source',signature=signature,outcome='Seen on corpse'},100)
   end
  end
 end
end
-- Use the client's translated chat formats, including positional placeholders.
function HP.ChatFormat(template,message)
 if type(template)~='string' or type(message)~='string' then return end
 local pieces,order={},{};local i,automatic=1,0
 while i<=#template do
  local rest=template:sub(i);local token,pos,spec=rest:match('^(%%(%d+)%$([sd]))')
  if not token then token,spec=rest:match('^(%%([sd]))') end
  if token then automatic=automatic+1;order[#order+1]=tonumber(pos) or automatic;pieces[#pieces+1]=spec=='d' and '(%d+)' or '(.-)';i=i+#token
  elseif rest:sub(1,2)=='%%' then pieces[#pieces+1]='%%';i=i+2
  else pieces[#pieces+1]=template:sub(i,i):gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])','%%%1');i=i+1 end
 end
 local captured={message:match('^'..table.concat(pieces)..'$')};if #captured==0 then return end
 local result={};for index,value in ipairs(captured) do result[order[index]]=value end;return result
end
local function selfName(name)
 local player=HP.Call(UnitName,'player');return name==player or type(name)=='string' and name:match('^[^-]+')==player
end
function HP.RecordRoll(rollID,choice)
 rollID=number(rollID);choice=number(choice);if not rollID then return end
 local run=HP.ActivityInit().current;if not run then return end
 local link=HP.Call(GetLootRollItemLink,rollID);if type(link)~='string' then return end
 for _,r in ipairs(run.rolls) do if r.rollID==rollID and r.link==link and r.outcome=='Pending' then r.choice=choice or r.choice;return end end
 append(run.rolls,{rollID=rollID,link=link,choice=choice,outcome='Pending'},100)
end
function HP.ActivityLootChat(message,lineID)
 local a=HP.ActivityInit();local run=a.current or a.last;local v=HP.activityRuntime;if not run or not v or type(message)~='string' then return end
 if number(lineID) then if v.chatSeen[lineID] then return end;v.chatSeen[lineID]=true;v.chatOrder[#v.chatOrder+1]=lineID;if #v.chatOrder>128 then v.chatSeen[table.remove(v.chatOrder,1)]=nil end end
 local link=message:match('(|c%x+|Hitem:.-|h.-|h|r)') or message:match('(|Hitem:.-|h.-|h)');if not link then return end
 local mine=false;local recipient;local quantity=1;local rollWinner=false
 for _,key in ipairs({'LOOT_ITEM_SELF_MULTIPLE','LOOT_ITEM_SELF','LOOT_ITEM_PUSHED_SELF_MULTIPLE','LOOT_ITEM_PUSHED_SELF','LOOT_ROLL_YOU_WON'}) do
  local match=HP.ChatFormat(_G[key],message);if match then mine=true;recipient=HP.Call(UnitName,'player') or 'You';quantity=tonumber(match[2]) or 1;rollWinner=key=='LOOT_ROLL_YOU_WON';break end
 end
 if not recipient then for _,key in ipairs({'LOOT_ROLL_WON','LOOT_ITEM_MULTIPLE','LOOT_ITEM'}) do local match=HP.ChatFormat(_G[key],message);if match then recipient=match[1];mine=selfName(recipient);quantity=tonumber(match[3]) or 1;rollWinner=key=='LOOT_ROLL_WON';break end end end
 if not recipient then
  for _,entry in ipairs({{'LOOT_ROLL_NEED_SELF',1},{'LOOT_ROLL_GREED_SELF',2},{'LOOT_ROLL_PASSED_SELF',0}}) do
   if HP.ChatFormat(_G[entry[1]],message) then for _,r in ipairs(run.rolls) do if r.link==link and r.outcome=='Pending' then r.choice=entry[2];break end end;return end
  end
  return
 end
 if recipient then for _,r in ipairs(run.rolls) do if r.link==link and r.outcome=='Pending' then r.outcome=mine and 'Won' or 'Lost';r.winner=recipient;break end end end
 if not rollWinner then
  local match
  for _,drop in ipairs(run.loot) do if drop.link==link and drop.outcome=='Seen on corpse' then match=drop;break end end
  if not match then for _,drop in ipairs(run.loot) do if drop.link==link and drop.recipient==recipient and drop.fromEncounter and not drop.chatConfirmed and clock()-(drop.at or 0)<10 then match=drop;drop.chatConfirmed=true;break end end end
  if not match then match={link=link,source='Loot chat - source unavailable'};append(run.loot,match,100) end
  match.recipient=recipient;match.quantity=quantity;match.outcome=mine and 'Received by you' or 'Received by '..recipient
 end
end
local function refreshPage()
 local p=HP.settings;if p and p:IsShown() and (p.page=='Statistics' or p.page=='Dungeons') then p.activityDirty=true end
end
local create=HP.CreateUI
function HP.CreateUI()
 create();HP.InitAnnouncements();if HP.db.activityTracking~=true then return end;HP.ActivityInit();HP.activityRuntime={chatSeen={},chatOrder={},currencyBalances={},mailRows={},mailRequested={}}
 HP.ActivityXP();HP.ActivityMoney();HP.ActivityHonor();HP.ScanCurrencies(true);HP.CheckDungeon()
 local v=HP.activityRuntime
 local frame=CreateFrame('Frame',nil,UIParent);HP.activityEvents=frame
 for _,event in ipairs({'PLAYER_MONEY','PLAYER_XP_UPDATE','PLAYER_LEVEL_UP','PLAYER_ENTERING_WORLD','ZONE_CHANGED_NEW_AREA','CURRENCY_DISPLAY_UPDATE','HONOR_XP_UPDATE','CHAT_MSG_COMBAT_HONOR_GAIN','PLAYER_PVP_KILLS_CHANGED','LOOT_OPENED','CHAT_MSG_LOOT','START_LOOT_ROLL','ENCOUNTER_END','ENCOUNTER_LOOT_RECEIVED','BOSS_KILL','LFG_COMPLETION_REWARD','TRADE_ACCEPT_UPDATE','TRADE_SHOW','TRADE_CLOSED','TRADE_REQUEST_CANCEL','UI_INFO_MESSAGE','PLAYER_TARGET_CHANGED','CHAT_MSG_SYSTEM','MAIL_SHOW','MAIL_INBOX_UPDATE'}) do pcall(frame.RegisterEvent,frame,event) end
 frame:SetScript('OnEvent',function(_,event,...)
  if HP.Suite and not HP.Suite:On('community') then return end
  local v=HP.activityRuntime
  local a,b,c,d,e,f,g,h,i,j,lineID=...
  if event=='PLAYER_MONEY' then HP.ActivityMoney()
  elseif event=='PLAYER_XP_UPDATE' then HP.ActivityXP()
  elseif event=='PLAYER_LEVEL_UP' then HP.ActivityXP(a)
  elseif event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' then HP.CheckDungeon()
  elseif event=='CURRENCY_DISPLAY_UPDATE' then if number(a) then HP.ActivityCurrency(a,b,c) else HP.ScanCurrencies(false) end
  elseif event=='MAIL_SHOW' or event=='MAIL_INBOX_UPDATE' then
   v.mailRows={};v.mailRequested={};for index=1,math.min(number(HP.Call(GetInboxNumItems)) or 0,100) do local invoice=HP.Call(GetInboxInvoiceInfo,index);local _,_,_,_,money=multi(GetInboxHeaderInfo,index);if invoice=='seller' and number(money) and money>0 then v.mailRows[index]=money end end
  elseif event=='HONOR_XP_UPDATE' or event=='CHAT_MSG_COMBAT_HONOR_GAIN' or event=='PLAYER_PVP_KILLS_CHANGED' then HP.ActivityHonor()
  elseif event=='LOOT_OPENED' then HP.RecordDungeonLoot()
  elseif event=='CHAT_MSG_LOOT' then HP.ActivityLootChat(a,lineID)
  elseif event=='START_LOOT_ROLL' then HP.RecordRoll(a,nil)
  elseif event=='PLAYER_TARGET_CHANGED' then HP.DungeonSource(HP.Call(UnitGUID,'target'))
  elseif event=='TRADE_SHOW' then v.trade=nil;v.tradeRecorded=false
  elseif event=='TRADE_ACCEPT_UPDATE' and number(a)==1 and number(b)==1 then v.trade={incoming=number(HP.Call(GetTargetTradeMoney)) or 0,outgoing=number(HP.Call(GetPlayerTradeMoney)) or 0,at=clock()}
  elseif event=='TRADE_REQUEST_CANCEL' then v.trade=nil
  elseif event=='UI_INFO_MESSAGE' and b==ERR_TRADE_COMPLETE and v.trade and not v.tradeRecorded and clock()-v.trade.at<30 then add('tradeIn',v.trade.incoming);add('tradeOut',v.trade.outgoing);v.tradeRecorded=true;v.trade=nil
  elseif event=='LFG_COMPLETION_REWARD' then HP.EndDungeon(true)
  elseif event=='BOSS_KILL' or event=='ENCOUNTER_END' and number(e)==1 then
   local run=HP.ActivityInit().current;if run then local seen=false;for _,boss in ipairs(run.bosses) do if boss.id==a then seen=true end end;if not seen then append(run.bosses,{id=a,name=b or 'Boss',at=clock()},40) end end
  elseif event=='ENCOUNTER_LOOT_RECEIVED' then
   local run=HP.ActivityInit().current;if run and type(c)=='string' then
    local drop;for _,entry in ipairs(run.loot) do if entry.link==c and entry.outcome=='Seen on corpse' then drop=entry;break end end
    if not drop then drop={link=c};append(run.loot,drop,100) end
    local boss;for _,entry in ipairs(run.bosses) do if entry.id==a then boss=entry.name end end
    drop.quantity=number(d) or 1;drop.source=boss or 'Encounter '..tostring(a);drop.recipient=e;drop.outcome=selfName(e) and 'Received by you' or 'Received by '..tostring(e);drop.fromEncounter=true;drop.at=clock()
   end
  elseif event=='CHAT_MSG_SYSTEM' and (HP.ChatFormat(INSTANCE_RESET_SUCCESS,a) or HP.ChatFormat(INSTANCE_RESET_FAILED,a)==nil and type(INSTANCES_RESET)=='string' and a==INSTANCES_RESET) then v.reset=true;if HP.ActivityInit().current then HP.EndDungeon(false) end end
  refreshPage()
 end)
 local elapsed=0;frame:SetScript('OnUpdate',function(_,dt)
  elapsed=elapsed+dt;if elapsed<2 then return end;elapsed=0
  local p=HP.settings;if p and p:IsShown() and (p.activityDirty or p.page=='Dungeons') and HP.Call(InCombatLockdown)~=true then
   local offset=HP.Call(p.scroll.GetVerticalScroll,p.scroll) or 0;p.activityDirty=false;p.ShowPage(p.page);p.scroll:SetVerticalScroll(math.min(offset,math.max(0,p.content:GetHeight()-p.scroll:GetHeight())))
  end
 end)
 if hooksecurefunc then
  if type(RollOnLoot)=='function' then hooksecurefunc('RollOnLoot',HP.RecordRoll) end
  if type(ResetInstances)=='function' then hooksecurefunc('ResetInstances',function() v.reset=true end) end
  if type(TakeInboxMoney)=='function' then hooksecurefunc('TakeInboxMoney',function(index)
   if v.mailRequested[index] then return end
   local invoice=HP.Call(GetInboxInvoiceInfo,index);local _,_,_,_,money=multi(GetInboxHeaderInfo,index)
   local amount=invoice=='seller' and number(money) or v.mailRows[index];if amount and amount>0 then if not v.mail or clock()-v.mail.at>=20 then v.mail={amount=0,items={}} end;v.mail.amount=v.mail.amount+amount;v.mail.items[#v.mail.items+1]=amount;v.mail.at=clock();v.mailRows[index]=nil;v.mailRequested[index]=true end
  end) end
 end
end
function HP.ActivitySummaryLines()
 local a=HP.ActivityInit();local t=a.total;local d=a.daily;local money=function(n) return HP.ActivityMoneyText(n) end
 local lines={'Current gold: '..(HP.activityRuntime.money and money(HP.activityRuntime.money) or 'Unavailable'),
 'Recorded since '..(HP.Call(date,'%Y-%m-%d',a.started) or 'installation')..' · this character',
 'XP gained: '..t.xp..'  |  Today: '..d.xp,
 'Gold balance increases: '..money(t.income)..'  |  Today: '..money(d.income),
 'Gold spent: '..money(t.spent)..'  |  Net: '..money(t.income-t.spent),
 'Auction sale mail collected: '..money(t.auction)..'  |  Today: '..money(d.auction),
 'Completed trades received: '..money(t.tradeIn)..'  |  Paid: '..money(t.tradeOut),
 'Honor gained: '..(HP.activityRuntime.honorAvailable and tostring(t.honor)..'  |  Today: '..d.honor or 'Unavailable on this client')}
 lines[#lines+1]='Other currencies gained:'
 local sorted={};for id,c in pairs(t.currencies) do sorted[#sorted+1]={id=id,data=c} end;table.sort(sorted,function(x,y) return x.data.name<y.data.name end)
 for _,entry in ipairs(sorted) do local c=entry.data;lines[#lines+1]=c.name..': +'..c.gained..'  |  Current: '..c.balance end
 if #sorted==0 then lines[#lines+1]='No reported currency gains recorded yet.' end
 lines[#lines+1]='Recorded while this addon is loaded. AH totals are collected sale proceeds, not profit; purchases, deposits and uncollected sales are not classified. Gold totals are balance changes; transfers can affect them.'
 return lines
end

end)
