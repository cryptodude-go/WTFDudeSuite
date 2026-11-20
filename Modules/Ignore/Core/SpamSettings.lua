local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'spam',function(...)
-- Native settings, rule editor, timestamped ignore/history browsers.
local _,HP=...
local D,S=HP.Native,HP.SpamFilter
local UI,Cfg=D.UI,D.Config
local function dt(value)
 if not value then return 'Original time unknown'end
 local fn=date or os and os.date
 return fn and fn('%Y-%m-%d %H:%M:%S',value)or tostring(value)
end
local function check(canvas,width,key,label,desc)
 return UI.CheckRow(canvas,Cfg,{label=label,desc=desc,default=S.defaults[key],get=function()return S:DB()[key]end,set=function(v)S:DB()[key]=v;S:Changed()end},width)
end
local function button(parent,text,x,run)
 local b=CreateFrame('Button',nil,parent);b:SetSize(90,26);b:SetPoint('BOTTOMRIGHT',x,12)
 local bg=b:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.25,.20,.04,.95)
 local label=UI.Text(b,'semibold',12,{1,.88,.3,1});label:SetPoint('CENTER');label:SetText(text)
 b:SetScript('OnClick',run);return b
end
function S:Editor(title,text,save,multiline)
 local f=self.editor
 if not f then
  f=CreateFrame('Frame','DudeDingSpamEditor',UIParent);f:SetSize(570,245);f:SetPoint('CENTER');f:SetFrameStrata('DIALOG');f:SetClampedToScreen(true);f:EnableMouse(true);f:SetMovable(true);f:RegisterForDrag('LeftButton')
  UI.Window(f,'dialog');f:SetScript('OnDragStart',function()f:StartMoving()end);f:SetScript('OnDragStop',function()f:StopMovingOrSizing()end)
  f.title=UI.Text(f,'semibold',14,UI.C.text);f.title:SetPoint('TOPLEFT',16,-15)
  local scroll=CreateFrame('ScrollFrame',nil,f,'UIPanelScrollFrameTemplate');scroll:SetPoint('TOPLEFT',18,-48);scroll:SetPoint('BOTTOMRIGHT',-36,53)
  local edit=CreateFrame('EditBox',nil,scroll);f.edit=edit;edit:SetWidth(510);edit:SetHeight(130);edit:SetMultiLine(true);edit:SetAutoFocus(false);edit:SetMaxLetters(8000);edit:SetFontObject(ChatFontNormal);scroll:SetScrollChild(edit)
  edit:SetScript('OnEscapePressed',function()edit:ClearFocus();f:Hide()end)
  edit:SetScript('OnEnterPressed',function()
   if not f.multiline then f.save(edit:GetText());edit:ClearFocus();f:Hide()end
  end)
  button(f,'Cancel',-112,function()edit:ClearFocus();f:Hide()end)
  button(f,'Save',-16,function()f.save(edit:GetText());edit:ClearFocus();f:Hide()end)
  if type(UISpecialFrames)=='table'then UISpecialFrames[#UISpecialFrames+1]='DudeDingSpamEditor'end
  self.editor=f
 end
 f.title:SetText(title);f.save=save;f.multiline=multiline;f.edit:SetText(text or '');f:Show();f.edit:SetFocus();f.edit:HighlightText()
end
local RULES={key='spamRules',title='Spam Filter · custom rules'}
local BLOCKS={key='spamBlocks',title='Spam Filter · ignored players'}
local HISTORY={key='spamHistory',title='Spam Filter · blocked messages'}
local TRUST={key='spamTrusted',title='Spam Filter · trusted players'}
S.rulesPage=RULES;S.blocksPage=BLOCKS;S.historyPage=HISTORY;S.trustPage=TRUST
local MODES={{value='word',text='Whole word / phrase'},{value='contains',text='Contains literal text'},{value='compact',text='Compact: ignore spaces / punctuation'}}
local function refresh(page)Cfg:OpenPage(page)end
local function rulePage(rule)
 local page={key='spamRule'..rule.id,title='Rule: '..rule.text}
 page.build=function(canvas,width)
  return {
   UI.CheckRow(canvas,Cfg,{label='Enabled',get=function()return rule.enabled end,set=function(v)rule.enabled=v;S:Changed()end},width),
   UI.ButtonRow(canvas,Cfg,{label='Word / phrase',desc=rule.text,button='Edit',run=function()S:Editor('Edit rule',rule.text,function(text)
    text=text:gsub('^%s+',''):gsub('%s+$',''):sub(1,160)
    if text~=''then rule.text=text;S:Changed();refresh(rulePage(rule))else D:Print('Empty rules are not allowed.')end
   end)end},width),
   UI.HeaderRow(canvas,'Match style',width),UI.DropdownRow(canvas,Cfg,{items=function()return MODES end,get=function()return rule.mode end,set=function(v)rule.mode=v;S:Changed()end},width),
   UI.HeaderRow(canvas,'Action',width),UI.DropdownRow(canvas,Cfg,{items=function()return {{value='ignore',text='Ignore sender and hide message'},{value='hide',text='Hide matching message only'}}end,get=function()return rule.action end,set=function(v)rule.action=v;S:Changed()end},width),
   UI.InfoRow(canvas,'Created: '..dt(rule.created)..' · Matches: '..(rule.hits or 0),width),
   UI.ButtonRow(canvas,Cfg,{label='Delete this rule',button='Delete',run=function()for i,r in ipairs(S:DB().rules)do if r==rule then table.remove(S:DB().rules,i);break end end;S:Changed();refresh(RULES)end},width)}
 end
 return page
end
RULES.build=function(canvas,width)
 local rows={UI.InfoRow(canvas,'Each rule is literal text, not code. Whole-word matching avoids partial names such as gold inside Goldshire. Custom ignore rules block the sender after one match. Deleting a rule does not unignore past matches.',width),
 UI.HeaderRow(canvas,'New rule match style',width),UI.DropdownRow(canvas,Cfg,{items=function()return MODES end,get=function()return S.newMode or 'word'end,set=function(v)S.newMode=v end},width),
 UI.ButtonRow(canvas,Cfg,{label='Add words / phrases',desc='One rule per line. Each defaults to Ignore sender.',button='Add',run=function()
  S:Editor('Add custom rules · one per line','',function(text)
   local added=0;local error
   for line in text:gmatch('[^\r\n]+')do local ok,why=S:AddRule(line,S.newMode or 'word','ignore');if ok then added=added+1 else error=why end end
   D:Print(tostring(added)..' rule(s) added.'..(error and ' '..error or ''));refresh(RULES)
  end,true)
 end},width)}
 for _,rule in ipairs(S:DB().rules)do
  local r=rule
  rows[#rows+1]=UI.PageRow(canvas,Cfg,{label=(r.enabled and '[ON] 'or '[OFF] ')..r.text,desc=r.mode..' · '..r.action..' · '..(r.hits or 0)..' matches',open=function()refresh(rulePage(r))end},width)
 end
 return rows
end
local function entryPage(entry)
 local e=entry;local page={key='spamPlayer'..e.key,title=e.name}
 page.build=function(canvas,width)
  local rows={
   UI.InfoRow(canvas,'Ignored since: '..(e.firstBlocked and dt(e.firstBlocked)or 'Unknown · first observed '..dt(e.observedAt))..'\nLast seen: '..dt(e.lastSeen)..'\nReason: '..e.reason..'\nWoW ignore: '..(e.nativeState or 'local only')..(e.nativeConfirmedAt and ' · confirmed '..dt(e.nativeConfirmedAt)or ''),width),
   UI.InfoRow(canvas,'Last message: '..(S:Clean(e.sample or '')or ''),width),
   UI.ButtonRow(canvas,Cfg,{label='Unignore in addon and WoW',desc='Removes this player only. The game may need a moment to update.',button='Unignore',run=function()
    local done=S:Unblock(e.key,true);D:Print(done and 'Unignored: '..e.name or 'Addon block removed; WoW still reports this player ignored.');refresh(BLOCKS)
   end},width),
   UI.ButtonRow(canvas,Cfg,{label='Unignore and trust this player',desc='Their future messages bypass our rules.',button='Trust',run=function()S:Unblock(e.key,true);S:DB().trusted[e.key]=e.name;S:Changed();refresh(BLOCKS)end},width),
   UI.ButtonRow(canvas,Cfg,{label='Try adding to WoW ignore',desc='Local blocking already works if WoW refuses or its list is full.',button='Retry',run=function()S:QueueNative(e,true);refresh(entryPage(e))end},width)}
  return rows
 end
 return page
end
BLOCKS.build=function(canvas,width)
 local list={}
 for _,e in pairs(S:DB().blocks)do if (e.active or e.nativeState=='still in WoW ignore'or e.nativeState=='WoW removal not confirmed')and(not S.listSearch or S.listSearch==''or S:Matches(e.name,S.listSearch,'contains'))then list[#list+1]=e end end
 table.sort(list,function(a,b)local x,y=a.firstBlocked or a.observedAt or 0,b.firstBlocked or b.observedAt or 0;if x~=y then return x>y end;return a.key<b.key end)
 local pages=math.max(1,math.ceil(#list/25));S.listPage=math.min(S.listPage or 1,pages)
 local rows={UI.InfoRow(canvas,#list..' ignored players · page '..S.listPage..' / '..pages..'. Timestamps use your local timezone.',width),
 UI.ButtonRow(canvas,Cfg,{label='Find player',desc=S.listSearch or '',button='Search',run=function()S:Editor('Find player · empty shows all',S.listSearch or '',function(t)S.listSearch=t;S.listPage=1;refresh(BLOCKS)end)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Manually ignore a player',desc='Full name, optionally followed by -Realm.',button='Add',run=function()S:Editor('Ignore player: First Last-Realm','',function(t)
  local key=S:Identity(t);if key and key~=S.selfKey then S:Block(t,nil,'Manual block',nil,'manual');S:Changed();refresh(BLOCKS)else D:Print('Enter a valid player name other than yourself.')end
 end)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Import the current WoW ignore list',desc='Old ignore timestamps are unknown; we record when first observed.',button='Import',run=function()D:Print(S:ImportNative()..' existing WoW ignores imported.');refresh(BLOCKS)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Refresh WoW ignore status',button='Refresh',run=function()S:SyncNative();refresh(BLOCKS)end},width)}
 for i=(S.listPage-1)*25+1,math.min(#list,S.listPage*25)do
  local e=list[i]
  rows[#rows+1]=UI.PageRow(canvas,Cfg,{label=e.name,desc=(e.firstBlocked and dt(e.firstBlocked)or 'Observed '..dt(e.observedAt))..' · '..e.nativeState,open=function()refresh(entryPage(e))end},width)
 end
 if S.listPage>1 then rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Previous page',button='Previous',run=function()S.listPage=S.listPage-1;refresh(BLOCKS)end},width)end
 if S.listPage<pages then rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Next page',button='Next',run=function()S.listPage=S.listPage+1;refresh(BLOCKS)end},width)end
 return rows
end
TRUST.build=function(canvas,width)
 local rows={UI.InfoRow(canvas,'Trusted names bypass our spam rules. Trusting a name does not silently remove an existing WoW ignore; use Unignore and trust from the ignored-player page.',width),
 UI.ButtonRow(canvas,Cfg,{label='Add trusted players',desc='One full name per line; -Realm is optional.',button='Add',run=function()S:Editor('Trusted players · one per line','',function(text)
  for line in text:gmatch('[^\r\n]+')do local key,name=S:Identity(line);if key then S:DB().trusted[key]=name end end;S:Changed();refresh(TRUST)
 end,true)end},width)}
 local keys={};for k in pairs(S:DB().trusted)do keys[#keys+1]=k end;table.sort(keys)
 for _,key in ipairs(keys)do local k=key;rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label=tostring(S:DB().trusted[k]),button='Remove',run=function()S:DB().trusted[k]=nil;S:Changed();refresh(TRUST)end},width)end
 return rows
end
HISTORY.build=function(canvas,width)
 local rows={UI.InfoRow(canvas,'Latest 200 blocked messages are saved locally. Nothing is reported or uploaded.',width),
 UI.ButtonRow(canvas,Cfg,{label='Clear message history',desc='Keeps ignore records and custom rules.',button='Clear',run=function()S:DB().history={};refresh(HISTORY)end},width)}
 S.historyPageIndex=S.historyPageIndex or 1
 local log=S:DB().history;local pages=math.max(1,math.ceil(#log/20));S.historyPageIndex=math.min(S.historyPageIndex,pages)
 for i=(S.historyPageIndex-1)*20+1,math.min(#log,S.historyPageIndex*20)do
  local e=log[i]
  rows[#rows+1]=UI.InfoRow(canvas,dt(e.at)..' · '..e.name..'\n'..e.reason..' · '..e.channel..'\n'..(S:Clean(e.text)or ''),width)
 end
 if S.historyPageIndex>1 then rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Previous page',button='Previous',run=function()S.historyPageIndex=S.historyPageIndex-1;refresh(HISTORY)end},width)end
 if S.historyPageIndex<pages then rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Next page',button='Next',run=function()S.historyPageIndex=S.historyPageIndex+1;refresh(HISTORY)end},width)end
 rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Refresh history',button='Refresh',run=function()refresh(HISTORY)end},width)
 return rows
end
local function build(canvas,width)
 local rows={
 check(canvas,width,'enabled','Enable Spam Filter','Turning this off does not remove existing WoW ignores.'),
 check(canvas,width,'gold','Detect gold-selling advertisements','Built-in conservative rules. Custom rules can add specific websites or phrases.'),
 check(canvas,width,'autoNative','Automatically add blocked senders to WoW ignore','Verified and rate-limited. Our extended local ignore remains active if WoW refuses.'),
 UI.PageRow(canvas,Cfg,{label='Custom words / phrases',desc='Each matching Ignore rule adds the sender to the block list.',open=function()refresh(RULES)end},width),
 UI.PageRow(canvas,Cfg,{label='Ignored players and timestamps',open=function()refresh(BLOCKS)end},width),
 UI.PageRow(canvas,Cfg,{label='Blocked message history',open=function()refresh(HISTORY)end},width),
 UI.PageRow(canvas,Cfg,{label='Trusted players',open=function()refresh(TRUST)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Test a message without ignoring anyone',desc=S.testResult or 'Tests rules only; does not modify either ignore list.',button='Test',run=function()S:Editor('Test message','',function(text)
  local action,reason=S:Match(text);S.testResult=action and 'Would '..action..': '..reason or 'No rule matched.';D:Print(S.testResult);Cfg:SelectTab(Cfg.TAB.spam)
 end,true)end},width),
 UI.HeaderRow(canvas,'Apply word rules to',width),check(canvas,width,'whisper','Incoming whispers'),check(canvas,width,'general','General /1'),check(canvas,width,'trade','Trade /2'),
 check(canvas,width,'otherChannels','Other public / custom channels'),check(canvas,width,'say','Say'),check(canvas,width,'yell','Yell'),check(canvas,width,'group','Party / raid / instance chat'),check(canvas,width,'guild','Guild / officer chat'),
 UI.HeaderRow(canvas,'Exceptions and existing blocks',width),check(canvas,width,'trustFriends','Exempt game friends from word rules'),check(canvas,width,'trustGroup','Exempt current group members from word rules'),
 check(canvas,width,'blockEverywhere','Hide ignored players across all supported chat channels','Includes channels whose word rules are disabled. Trusted players still bypass our filter.')}
 local status=UI.InfoRow(canvas,'',width)
 function status:Refresh()
  local active=S:Counts();self.text:SetText(active..' ignored · '..S:DB().stats.hidden..' hidden messages · '..#S:DB().rules..' custom rules'..(not S.registered and '\nChat filter API is unavailable.'or '')..(S.nativeBlocked and '\nWoW ignore API blocked this session; local ignores remain active.'or '')..(S.lastError and '\nLast error: '..S.lastError or ''))
 end
 status:SetHeight(60);status:Refresh();S.statusRow=status;rows[#rows+1]=status
 return rows
end
Cfg.TABS[#Cfg.TABS+1]={key='spam',label='Spam Filter',build=build,pad=UI.SIZE.pad,gap=UI.SIZE.gap};Cfg.TAB.spam=#Cfg.TABS
local slash=SlashCmdList.DUDEWHERESMYDING
SlashCmdList.DUDEWHERESMYDING=function(input)
 local sub=(input or ''):lower():match('^%s*spam%s*(.-)%s*$')
 if sub~=nil then
  if sub=='on'or sub=='off'then S:DB().enabled=sub=='on';S:Changed();D:Print('Spam Filter '..(sub=='on'and 'enabled.'or 'disabled.'))
  else Cfg:Open('spam')end;return
 end
 return slash(input)
end
local ticker=CreateFrame('Frame');local elapsed=0
ticker:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<1 then return end;elapsed=0
 if Cfg.frame and Cfg.frame:IsShown()and Cfg.tab==Cfg.TAB.spam and not Cfg.page and S.statusRow then S.statusRow:Refresh()end
end)

end)
