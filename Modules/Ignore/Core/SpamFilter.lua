local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'spam',function(...)
-- Local spam ignores and a verified, rate-limited bridge to the game's ignore list.
-- Independent implementation. No reports, chat replies, external services or code patterns.
local _,HP=...
local D=HP.Native
local S={queue={},queued={},manualNative={},pending={},seen={},seenOrder={},revision=0};HP.SpamFilter=S
local DEFAULT={enabled=true,gold=true,autoNative=true,whisper=true,general=true,trade=true,otherChannels=false,say=false,yell=false,group=false,guild=false,trustFriends=true,trustGroup=true,blockEverywhere=true}
local EVENTS={'CHAT_MSG_WHISPER','CHAT_MSG_CHANNEL','CHAT_MSG_SAY','CHAT_MSG_YELL','CHAT_MSG_GUILD','CHAT_MSG_OFFICER','CHAT_MSG_PARTY','CHAT_MSG_PARTY_LEADER','CHAT_MSG_RAID','CHAT_MSG_RAID_LEADER','CHAT_MSG_RAID_WARNING','CHAT_MSG_INSTANCE_CHAT','CHAT_MSG_INSTANCE_CHAT_LEADER','CHAT_MSG_EMOTE','CHAT_MSG_TEXT_EMOTE'}
local function plain(v)
 if type(issecretvalue)=='function'then local ok,secret=pcall(issecretvalue,v);if not ok or secret then return nil end end
 return v
end
local function call(fn,...)
 if type(fn)~='function'then return nil,false end
 local ok,v=pcall(fn,...);if not ok then return nil,false end
 return plain(v),true
end
local function clock()return GetTime()end
local function epoch()return tonumber((call(GetServerTime)))or tonumber((call(time)))or os and os.time and os.time()or 0 end
local function trim(s)return(s:gsub('^%s+',''):gsub('%s+$',''))end
-- Case fold ASCII plus common Latin-1, Greek and Cyrillic (including Macedonian).
local function lower(s)
 s=s:lower()
 return(s:gsub('[\194-\223][\128-\191]',function(c)
  local a,b=c:byte(1,2);local n=(a-192)*64+b-128
  if n>=192 and n<=214 or n>=216 and n<=222 or n>=913 and n<=929 or n>=931 and n<=939 or n>=1040 and n<=1071 then n=n+32
  elseif n>=1024 and n<=1039 then n=n+80 else return c end
  return string.char(192+math.floor(n/64),128+n%64)
 end))
end
function S:DB()
 if not D.db then return end
 local db=D.db.spamFilter
 if not db then db={rules={},blocks={},trusted={},history={},nextRule=0,stats={hidden=0,autoBlocked=0}};D.db.spamFilter=db end
 for k,v in pairs(DEFAULT)do if db[k]==nil then db[k]=v end end
 return db
end
function S:Changed()self.revision=self.revision+1;self.seen={};self.seenOrder={};self.compiled=nil end
function S:Clean(text)
 if type(plain(text))~='string'then return end
 local s=text:sub(1,4096)
 s=s:gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):gsub('|H.-|h(.-)|h','%1'):gsub('|T.-|t',' '):gsub('|A.-|a',' ')
 for _,z in ipairs({'\226\128\139','\226\128\140','\226\128\141','\239\187\191'})do s=s:gsub(z,'')end
 return lower(s):gsub('[%c]',' '):gsub('%s+',' ')
end
function S:Identity(author)
 if type(plain(author))~='string'then return end
 local name=trim(author:gsub('%s+',' '))
 if #name<2 or #name>120 or name:find('[|%c]')then return end
 local char,realm=name:match('^(.-)%-(.+)$')
 if not char then char=name;realm=call(GetNormalizedRealmName)or call(GetRealmName)or 'unknown' end
 if type(realm)~='string'or char==''then return end
 realm=lower(realm):gsub('%s+','')
 return lower(char)..'-'..realm,name
end
local function wordByte(c)return c and(c>=128 or c>=48 and c<=57 or c>=65 and c<=90 or c>=97 and c<=122 or c==95)end
function S:MatchesNormalized(clean,needle,mode)
 if not clean or not needle or trim(needle)==''then return false end
 if mode=='compact'then
  clean=clean:gsub('[%s%p]','');needle=needle:gsub('[%s%p]','')
  return needle~=''and clean:find(needle,1,true)~=nil
 end
 local start=1
 while true do
  local a,b=clean:find(needle,start,true);if not a then return false end
  if mode=='contains'or not wordByte(clean:byte(a-1))and not wordByte(clean:byte(b+1))then return true end
  start=a+1
 end
end
function S:Matches(text,needle,mode)
 return self:MatchesNormalized(self:Clean(text),self:Clean(needle),mode)
end
function S:Gold(text)
 local c=self:Clean(text);if not c then return false end
 c=c:gsub('%f[%a]g[%s%p_]*[o0][%s%p_]*l[%s%p_]*d%f[%A]','gold')
 local words=' '..c:gsub('[%p%c]',' '):gsub('%s+',' ')..' '
 for _,neg in ipairs({'do not buy gold','don t buy gold','stop buying gold','report gold sellers'})do if words:find(' '..neg..' ',1,true)then return false end end
 local material=words:find(' gold ore ',1,true)or words:find(' gold bar ',1,true)or words:find(' gold bars ',1,true)
 local intent=false
 for _,term in ipairs({'buy gold','cheap gold','sell gold','selling gold','wts gold','gold for sale','gold delivery'})do if words:find(' '..term..' ',1,true)then intent=true;break end end
 if not intent then return false end
 local link=c:find('https?://')or c:find('www[%s%.]')or c:find('%.[%s]*com%f[%A]')or c:find('%.[%s]*net%f[%A]')or c:find('%.[%s]*gg%f[%A]')
 local financial=c:find('%$')or c:find('€',1,true)or words:find(' usd ',1,true)or words:find(' eur ',1,true)or words:find(' paypal ',1,true)
 local commerce=financial
 for _,term in ipairs({'usd','eur','paypal','discount','coupon','delivery','instant delivery','24 7'})do if words:find(' '..term..' ',1,true)then commerce=true end end
 if material and not financial then return false end
 local direct=words:match('^%s*wts%s+gold%s*$')or words:match('^%s*selling%s+gold%s*$')or words:find(' gold for sale ',1,true)or words:find(' wts gold pm ',1,true)
 if c:find('wowhead.com',1,true)or c:find('blizzard.com',1,true)then link=false end
 return (intent and(link or commerce)or direct and not material)and true or false
end
function S:Match(text)
 local db=self:DB();if not db then return end
 local clean=self:Clean(text);if not clean then return end
 self.compiled=self.compiled or {}
 for _,r in ipairs(db.rules)do
  if r.enabled then
   local needle=self.compiled[r.id]
   if not needle then needle=self:Clean(r.text);self.compiled[r.id]=needle end
   if self:MatchesNormalized(clean,needle,r.mode)then return r.action or 'ignore','Custom: '..r.text,r end
  end
 end
 if db.gold and self:Gold(text)then return 'ignore','Gold-selling advertisement' end
end
function S:AddRule(text,mode,action)
 local db=self:DB();if not db or type(text)~='string'then return false,'Enter a word or phrase.' end
 text=trim(text):sub(1,160)
 if text==''then return false,'Empty rules are not allowed.' end
 mode=(mode=='contains'or mode=='compact')and mode or 'word'
 local folded=self:Clean(text)
 if mode=='compact'and folded:gsub('[%s%p]','')==''then return false,'Compact rules need letters or numbers.' end
 for _,r in ipairs(db.rules)do if self:Clean(r.text)==folded and r.mode==mode then return false,'Rule already exists.' end end
 if #db.rules>=500 then return false,'Maximum 500 custom rules.' end
 db.nextRule=db.nextRule+1
 db.rules[#db.rules+1]={id=db.nextRule,text=text,mode=mode,action=action=='hide'and 'hide'or 'ignore',enabled=true,hits=0,created=epoch()}
 self:Changed();return true
end
function S:Scope(event,zone,index)
 local db=self:DB()
 if event=='CHAT_MSG_WHISPER'then return db.whisper end
 if event=='CHAT_MSG_CHANNEL'then
  if zone==1 then return db.general elseif zone==2 then return db.trade end
  -- Old clients without a stable zone channel ID can still expose /1 and /2.
  if not zone or zone==0 then if index==1 then return db.general elseif index==2 then return db.trade end end
  return db.otherChannels
 end
 if event=='CHAT_MSG_SAY'then return db.say end
 if event=='CHAT_MSG_YELL'then return db.yell end
 if event=='CHAT_MSG_GUILD'or event=='CHAT_MSG_OFFICER'then return db.guild end
 if event:find('PARTY',1,true)or event:find('RAID',1,true)or event:find('INSTANCE_CHAT',1,true)then return db.group end
 return false
end
function S:RefreshTrusted()
 local group={};local function add(unit)
  local guid=call(UnitGUID,unit);if type(guid)=='string'then group[guid]=true end
  local name,realm
  if type(UnitFullName)=='function'then local ok,a,b=pcall(UnitFullName,unit);if ok then name,realm=plain(a),plain(b)end end
  name=name or call(UnitName,unit)
  if type(name)=='string'then local key=self:Identity(name..(type(realm)=='string'and realm~=''and '-'..realm or ''));if key then group[key]=true end end
 end
 add('player');for i=1,4 do add('party'..i)end;for i=1,40 do add('raid'..i)end
 self.group=group
 self.selfGUID=call(UnitGUID,'player')
 local name=call(UnitName,'player')
 if type(UnitFullName)=='function'then
  local ok,a,b=pcall(UnitFullName,'player');a,b=plain(a),plain(b)
  if ok and type(a)=='string'then name=a..(type(b)=='string'and b~=''and '-'..b or '')end
 end
 self.selfKey=name and self:Identity(name)
end
function S:Trusted(key,guid,explicitOnly)
 local db=self:DB()
 if key==self.selfKey or guid and guid==self.selfGUID or db.trusted[key]then return true end
 if explicitOnly then return false end
 if db.trustGroup and self.group and(self.group[key]or guid and self.group[guid])then return true end
 if db.trustFriends and guid and call(C_FriendList and C_FriendList.IsFriend,guid)==true then return true end
 return false
end
function S:NativeIgnored(entry)
 local f=C_FriendList
 if entry.guid then local value=call(f and f.IsIgnoredByGuid,entry.guid);if value==true then return true end end
 local value,ok=call(f and(f.IsIgnored or f.IsOnIgnoredList)or IsIgnored,entry.name)
 if ok and type(value)=='boolean'then return value end
 local count=call(f and f.GetNumIgnores or GetNumIgnores)
 if type(count)~='number'then return nil end
 for i=1,math.min(count,1000)do
  local name=call(f and f.GetIgnoreName or GetIgnoreName,i)
  if name and self:Identity(name)==entry.key then return true end
 end
 return false
end
function S:QueueNative(entry,manual)
 local db=self:DB()
 if not entry.active or not manual and not db.autoNative then return end
 if self.queued[entry.key]or self.pending[entry.key]or entry.nativeState=='confirmed'then return end
 if manual then self.nativeBackoff=nil end
 self.queued[entry.key]=true;self.manualNative[entry.key]=manual==true;self.queue[#self.queue+1]=entry.key;entry.nativeState='queued'
end
function S:Block(author,guid,reason,message,source)
 local db=self:DB();local key,name=self:Identity(author);if not key then return end
 guid=plain(guid);if type(guid)~='string'or not guid:match('^Player%-')then guid=nil end
 local entry=db.blocks[key]
 if not entry or not entry.active then
  entry={key=key,name=name,guid=guid,active=true,firstBlocked=epoch(),lastSeen=epoch(),reason=reason or 'Manual',source=source or 'manual',hits=0,nativeState='local only'}
  db.blocks[key]=entry
  if source=='auto'then db.stats.autoBlocked=db.stats.autoBlocked+1 end
 end
 entry.guid=guid or entry.guid;entry.lastSeen=epoch();entry.hits=entry.hits+1
 if message then entry.sample=tostring(message):sub(1,400)end
 self:QueueNative(entry)
 return entry
end
function S:Log(author,reason,message,channel,action)
 local log=self:DB().history
 table.insert(log,1,{at=epoch(),name=author,reason=reason,text=message:sub(1,400),channel=channel,action=action})
 while #log>200 do table.remove(log)end
end
function S:Filter(event,message,author,language,channel,other,flags,zone,index,base,languageID,lineID,guid)
 if HP.Suite and not HP.Suite:On('spam') then return false end
 local db=self:DB();if not db or not db.enabled then return false end
 message,author,guid,lineID,flags,zone,index=plain(message),plain(author),plain(guid),plain(lineID),plain(flags),plain(zone),plain(index)
 if type(message)~='string'or type(author)~='string'then return false end
 if flags=='GM'or flags=='DEV'then return false end
 local key=self:Identity(author);if not key or self:Trusted(key,guid,true)then return false end
 local scoped=self:Scope(event,zone,index)
 local entry=db.blocks[key]
 local block=entry and entry.active and(db.blockEverywhere or scoped)
 if not scoped and not block then return false end
 if not block and self:Trusted(key,guid)then return false end
 local id=event..':'..key..':'..(type(lineID)=='number'and lineID>0 and tostring(lineID)or message:sub(1,600))
 local cached=self.seen[id]
 if cached and clock()-cached.at<3 then return cached.hide end
 local action,reason,rule
 if block then action,reason='ignore',entry.reason else action,reason,rule=self:Match(message)end
 local hide=action~=nil
 local decision={at=clock(),hide=hide};self.seen[id]=decision;self.seenOrder[#self.seenOrder+1]={id=id,decision=decision}
 while #self.seenOrder>256 do local old=table.remove(self.seenOrder,1);if self.seen[old.id]==old.decision then self.seen[old.id]=nil end end
 if not hide then return false end
 db.stats.hidden=db.stats.hidden+1
 if rule then rule.hits=(rule.hits or 0)+1 end
 if action=='ignore'then
  if not block then entry=self:Block(author,guid,reason,message,'auto')else entry.lastSeen=epoch();entry.hits=entry.hits+1 end
 end
 self:Log(author,reason,message,event,action)
 return true
end
function S:Tick()
 if HP.Suite and not HP.Suite:On('spam') then return end
 local db=self:DB();if not db then return end
 for key,pending in pairs(self.pending)do
  local e=db.blocks[key]
  if not e or not e.active then self.pending[key]=nil
  elseif self:NativeIgnored(e)==true then
   e.nativeState='confirmed';e.nativeCharacter=self.selfKey;e.nativeAddedByUs=true;e.nativeConfirmedAt=e.nativeConfirmedAt or epoch();self.pending[key]=nil
  elseif clock()>pending.deadline then e.nativeState='not confirmed';self.pending[key]=nil end
 end
 if not db.enabled or call(InCombatLockdown)==true or self.nextNative and clock()<self.nextNative or self.nativeBackoff and clock()<self.nativeBackoff then return end
 while #self.queue>0 do
  local key=table.remove(self.queue,1);self.queued[key]=nil;local e=db.blocks[key]
  local manual=self.manualNative[key];self.manualNative[key]=nil
  if e and e.active and(db.autoNative or manual)then
   self.nextNative=clock()+1.5
   if self:NativeIgnored(e)==true then e.nativeState='confirmed';e.nativeCharacter=self.selfKey;e.nativePreexisting=true;return end
   if self.nativeBlocked then e.nativeState='API blocked; local ignore active';return end
   local add=C_FriendList and C_FriendList.AddIgnore or AddIgnore
   if type(add)~='function'then e.nativeState='unavailable';return end
   local result,ok=call(add,e.name)
   if not ok then self.nativeBlocked=true;e.nativeState='API error; local ignore active';return end
   if result==false then self.nativeBackoff=clock()+60;e.nativeState='rejected / unavailable';return end
   e.nativeRequestedByUs=true;e.nativeCharacter=self.selfKey
   e.nativeState='pending confirmation';self.pending[key]={deadline=clock()+5}
   return
  elseif e and e.active then e.nativeState='local only (automatic WoW ignore off)'
  end
 end
end
function S:Unblock(key,removeNative)
 local db=self:DB();local e=db.blocks[key];if not e then return end
 e.active=false;e.unblockedAt=epoch();self.queued[key]=nil;self.pending[key]=nil
 local remaining=false
 if removeNative and(e.nativeAddedByUs or e.nativeRequestedByUs or e.nativePreexisting or e.nativeState=='confirmed')then
  call(C_FriendList and C_FriendList.DelIgnore or DelIgnore,e.name)
  local ignored=self:NativeIgnored(e)
  remaining=ignored~=false
  e.nativeState=ignored==false and 'removed'or (ignored==true and 'still in WoW ignore'or 'WoW removal not confirmed')
 end
 self:Changed();return not remaining
end
function S:ImportNative()
 local f=C_FriendList;local count=call(f and f.GetNumIgnores or GetNumIgnores);if type(count)~='number'then return 0 end
 local added=0
 for i=1,math.min(1000,count)do
  local name=call(f and f.GetIgnoreName or GetIgnoreName,i);local key=self:Identity(name)
  if key and(not self:DB().blocks[key]or not self:DB().blocks[key].active)then
   self:DB().blocks[key]={key=key,name=name,active=true,source='import',reason='Existing WoW ignore',observedAt=epoch(),hits=0,nativeState='confirmed',nativePreexisting=true,nativeCharacter=self.selfKey};added=added+1
  end
 end
 self:Changed();return added
end
function S:Counts()
 local active,total=0,0
 for _,e in pairs(self:DB().blocks)do total=total+1;if e.active then active=active+1 end end
 return active,total
end
function S:Init()
 if not self:DB()then return end
 self:RefreshTrusted()
 if not self.rehydrated then
  self.rehydrated=true
  for _,e in pairs(self:DB().blocks)do
   if e.active and e.nativeCharacter and e.nativeCharacter~=self.selfKey then
    e.nativeState='local only (different character)';e.nativeAddedByUs=nil;e.nativeRequestedByUs=nil;e.nativePreexisting=nil;self:QueueNative(e)
   elseif e.active and(e.nativeState=='queued'or e.nativeState=='pending confirmation')then e.nativeState='local only';self:QueueNative(e)
   end
  end
 end
 if not self.registered and type(ChatFrame_AddMessageEventFilter)=='function'then
  self.callback=function(_,event,...)
   local ok,hide=pcall(S.Filter,S,event,...)
   if not ok then S.lastError=tostring(hide);return false end
   return hide
  end
  for _,event in ipairs(EVENTS)do ChatFrame_AddMessageEventFilter(event,self.callback)end
  self.registered=true
 end
end
D:On('PLAYER_LOGIN',function()S:Init()end)
D:On('GROUP_ROSTER_UPDATE',function()if S:DB()then S:RefreshTrusted()end end)
D:On('IGNORELIST_UPDATE',function()if S:DB()then S:Tick()end end)
local ticker=CreateFrame('Frame');S.ticker=ticker;local elapsed=0
ticker:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<.5 then return end;elapsed=0
 if HP.nativeStarted then local ok,err=pcall(S.Tick,S);if not ok then S.lastError=tostring(err)end end
end)
S.Epoch=epoch;S.Plain=plain;S.defaults=DEFAULT

D:On('ADDON_ACTION_FORBIDDEN',function(_,addon,func)
 if addon=='WTFDudeSuite'and type(plain(func))=='string'and func:find('Ignore',1,true)then S.nativeBlocked=true end
end)
function S:SyncNative()
 local n=0
 for _,e in pairs(self:DB().blocks)do
  if e.active or e.nativeState=='still in WoW ignore'or e.nativeState=='WoW removal not confirmed'then
   local ignored=self:NativeIgnored(e)
   if ignored==true then e.nativeState=e.active and 'confirmed'or 'still in WoW ignore';e.nativeCharacter=self.selfKey;e.nativeConfirmedAt=e.nativeConfirmedAt or epoch();n=n+1
   elseif ignored==false then
    if not e.active then e.nativeState='removed'elseif e.nativeState=='confirmed'then e.nativeState='local only (removed in WoW)'end
   end
  end
 end
 return n
end

end)
