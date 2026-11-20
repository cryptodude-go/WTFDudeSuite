local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'marking',function(...)
-- Group pull planning and hardware-click marking for Forever.
-- Independently implemented using Blizzard's SecureActionButton raidtarget action.
-- No timer, event or slash command places or removes a raid target icon.
-- Combat uses explicit, preconfigured icon buttons; planning never drives protected actions.
local _,HP=...
local D=HP.Native
local UI,Cfg=D.UI,D.Config
local M={owned={},uncertain={},pending=nil,plan={},status='Disabled.'};HP.GroupMarks=M
local ICONS={[8]='Skull',[7]='Cross',[6]='Square',[5]='Moon',[4]='Triangle',[3]='Diamond',[2]='Circle',[1]='Star'}
local KILL_ORDER={8,7,5,6,4,3,2,1}
local DEFAULTS={enabled=false,party=true,raid=true,instances=true,outdoors=true,leaderOnly=true,nearby=true,cc=false,showBar=true,combatTarget=true,combatIcon=8,combatMode="palette",castersPriority=true}
local function read(fn,...)
 if type(fn)~='function'then return nil,false end
 local ok,v=pcall(fn,...)
 if not ok then return nil,false end
 if type(issecretvalue)=='function'then local good,secret=pcall(issecretvalue,v);if not good or secret then return nil,false end end
 return v,true
end
local function combat()return read(InCombatLockdown)==true end
local function stamp()return GetTime()end
function M:DB()
 if not D.db then return end
 D.db.ui.groupMarks=D.db.ui.groupMarks or {}
 local db=D.db.ui.groupMarks
 for k,v in pairs(DEFAULTS)do if db[k]==nil then db[k]=v end end
 db.priority=db.priority or {}
 db.casters=db.casters or {}
 db.npcRules=db.npcRules or {}
 return db
end
local function raid()
 if type(IsInRaid)=='function'then return read(IsInRaid)==true end
 return (tonumber((read(GetNumRaidMembers))) or 0)>0
end
function M:Members()
 local out={'player'}
 if raid()then
  local count=tonumber((read(GetNumGroupMembers))) or tonumber((read(GetNumRaidMembers))) or 0
  for i=1,math.min(40,count)do out[#out+1]='raid'..i end
 else
  local count=tonumber((read(GetNumSubgroupMembers))) or tonumber((read(GetNumPartyMembers))) or 0
  for i=1,math.min(4,count)do out[#out+1]='party'..i end
 end
 return out
end
function M:Context()
 if HP.Suite and not HP.Suite:On('marking') then return false, 'Group marking disabled in Suite settings.' end
 local db=self:DB();if not db or not db.enabled then return false,'Disabled.' end
 if not D.Compat.InGroup()then return false,'Join a party or raid.' end
 local inRaid=raid()
 if inRaid and not db.raid or not inRaid and not db.party then return false,'This group type is disabled.' end
 local leader=read(UnitIsGroupLeader,'player')==true or read(IsPartyLeader)==true
 local assistant=read(UnitIsGroupAssistant,'player')==true
 if inRaid and not(leader or assistant)then return false,'Raid leader / assistant permission needed.' end
 if db.leaderOnly and not(leader or inRaid and assistant)then return false,'Waiting for group leadership.' end
 local inside,kind=false,'none'
 if type(IsInInstance)=='function'then
  local ok,a,b=pcall(IsInInstance)
  if ok then inside=D.Compat.Plain(a)==true;kind=D.Compat.Plain(b) or 'none' end
 end
 if kind=='pvp' or kind=='arena'then return false,'PvP marking is not supported.' end
 if inside and kind~='party' and kind~='raid'then return false,'This instance type is not supported.' end
 if inside and not db.instances or not inside and not db.outdoors then return false,'This location is disabled.' end
 if type(RegisterStateDriver)~='function'or not self.driverBound then return false,'Secure marking is unavailable on this client.' end
 if combat()then
  local fixed=self.combatSnapshot
  return false,fixed and (db.combatMode=='fixed' and ('Combat: select an enemy; press Mark for '..ICONS[fixed]..'.')or 'Combat: choose Skull / Cross / Moon below; existing marks stay until you explicitly replace them.')or 'Combat marking is off; enable it before the pull.'
 end
 return true,(inRaid and 'Raid' or 'Party')..(inside and ' · Instance' or ' · Outdoors')..' · Before pull'
end
local function world(unit)
 if type(UnitPosition)~='function'then return end
 local ok,n,w,_,instance=pcall(UnitPosition,unit)
 if not ok then return end
 n,w,instance=D.Compat.Plain(n),D.Compat.Plain(w),D.Compat.Plain(instance)
 if type(n)=='number'and type(w)=='number'and type(instance)=='number'then return {n,w,instance}end
end
local function distance(a,b)
 if not a or not b or a[3]~=b[3]then return end
 return math.sqrt((a[1]-b[1])^2+(a[2]-b[2])^2)
end
local function npcID(guid)
 if type(guid)~='string'then return end
 local kind,id=guid:match('^([^-]+)%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)%-')
 if kind=='Creature' or kind=='Vehicle'then return tonumber(id)end
end
function M:Candidate(unit)
 if read(UnitExists,unit)~=true or read(UnitCanAttack,'player',unit)~=true then return end
 local dead,deadKnown=read(UnitIsDeadOrGhost,unit)
 if not deadKnown or dead then return end
 local player,playerKnown=read(UnitIsPlayer,unit)
 if not playerKnown or player then return end
 local guid=read(UnitGUID,unit)
 -- Never guess identities from recycled nameplate tokens or secret values.
 local id=npcID(guid);if not id then return end
 local icon,marksKnown=read(GetRaidTargetIndex,unit)
 if icon==0 then icon=nil end
 if not marksKnown then return end
 local name=read(UnitName,unit)
 return {unit=unit,guid=guid,npc=id,name=type(name)=='string'and name or 'NPC '..id,icon=icon,pos=world(unit)}
end
function M:Units()
 local units={'target','mouseover','focus','player','pet'};local seen={}
 for _,member in ipairs(self:Members())do
  units[#units+1]=member;units[#units+1]=member..'target';units[#units+1]=member..'pet'
 end
 local plates=read(C_NamePlate and C_NamePlate.GetNamePlates)
 if type(plates)=='table'then for _,plate in ipairs(plates)do
  local unit=read(function()return plate.namePlateUnitToken end)
  if type(unit)=='string'then units[#units+1]=unit end
 end end
 local unique={}
 for _,u in ipairs(units)do if not seen[u]then unique[#unique+1]=u;seen[u]=true end end
 return unique
end
function M:Engaged(unit,members)
 local victim=unit..'target'
 for _,member in ipairs(members)do
  if read(UnitIsUnit,victim,member)==true or read(UnitIsUnit,victim,member..'pet')==true then return true end
  local threat=read(UnitThreatSituation,member,unit)
  if type(threat)=='number'and threat>=0 then return true end
 end
 return false
end
local CREATURES={Beast=1,Dragonkin=2,Demon=3,Elemental=4,Giant=5,Undead=6,Humanoid=7,Critter=8}
local CC={
 {class='ROGUE',icon=3,spell=6770,types={[7]=true}},
 {class='PRIEST',icon=1,spell=9484,types={[6]=true}},
 {class='WARLOCK',icon=4,spell=710,types={[3]=true,[4]=true}},
 {class='DRUID',icon=2,spell=2637,types={[1]=true,[2]=true}},
 {class='MAGE',icon=5,spell=118,types={[1]=true,[7]=true,[8]=true}},
 {class='HUNTER',icon=6,spell=1499,types={[1]=true,[2]=true,[3]=true,[5]=true,[6]=true,[7]=true}},
}
function M:CCOptions(members)
 local result,extras,claimed,seen={},{},{},{}
 for rank,rule in ipairs(CC)do
  local first=true
  for _,member in ipairs(members)do
   local guid=read(UnitGUID,member)
   local identity=guid or (read(UnitIsUnit,member,'player')==true and 'player') or member
   local ok,_,class=pcall(UnitClass,member);class=ok and D.Compat.Plain(class)
   if class==rule.class and not seen[identity]then
    seen[identity]=true
    local item={class=class,icon=rule.icon,spell=rule.spell,types=rule.types,member=member,rank=rank}
    if first then result[#result+1]=item;claimed[rule.icon]=true;first=false
    else extras[#extras+1]=item end
   end
  end
 end
 for _,item in ipairs(extras)do
  for _,icon in ipairs(KILL_ORDER)do
   if icon~=8 and icon~=7 and not claimed[icon]then
    item.icon=icon;item.borrowed=true;claimed[icon]=true;result[#result+1]=item;break
   end
  end
 end
 table.sort(result,function(a,b)
  local ac,bc=0,0;for _ in pairs(a.types)do ac=ac+1 end;for _ in pairs(b.types)do bc=bc+1 end
  if ac~=bc then return ac<bc end
  if a.rank~=b.rank then return a.rank<b.rank end
  return a.icon<b.icon
 end)
 return result
end
local function creature(unit)
 if type(UnitCreatureType)~='function'then return end
 local ok,name,id=pcall(UnitCreatureType,unit)
 if not ok then return end
 id,name=D.Compat.Plain(id),D.Compat.Plain(name)
 if type(id)=='number'then return id end
 return type(name)=='string'and CREATURES[name] or nil
end
-- Global marker availability also covers off-screen units placed by another player.
function M:IconInUse(icon,includeDead)
 if type(GetNextAvailableRaidTargetMarkerIndex)~='function'then return nil end
 local nextFree,known=read(GetNextAvailableRaidTargetMarkerIndex,icon,false,false,includeDead~=true)
 if not known or type(nextFree)~='number'then return nil end
 return nextFree~=icon
end
function M:CheckClear()
 local attempt=self.clearAttempt;if not attempt then return end
 local allFree=true
 for icon=1,8 do if self:IconInUse(icon,true)~=false then allFree=false;break end end
 if allFree then
  self.owned={};self.uncertain={};self.pending=nil;self.clearAttempt=nil;self.pullEndedPending=nil
  self.notice='All raid marks cleared and verified.'
 elseif stamp()>attempt.expires then
  self.clearAttempt=nil;self.notice='Clear could not be fully verified. Check group permission / visible marks; tracking is preserved.'
 end
end
function M:SetRule(key,value)
 local c=self:Candidate('target');if not c then D:Print('Select a readable hostile NPC first.');return end
 local db=self:DB();db.npcRules[c.npc]=db.npcRules[c.npc]or {}
 local rule=db.npcRules[c.npc];rule[key]=value;rule.name=c.name
 self:Scan();self:Paint()
end
function M:TargetRule()
 local c=self:Candidate('target');return c and self:DB().npcRules[c.npc]or {}
end
-- Ownership is recorded only after the game exposes the requested mark. One
-- icon has one owner, including when its former owner is no longer on screen.
function M:RememberMark(guid,unit,icon,pullEnded)
 for other,entry in pairs(self.owned)do
  if other~=guid and entry.icon==icon then self.owned[other]=nil end
 end
 for other,entry in pairs(self.uncertain)do
  if other~=guid and entry.icon==icon then self.uncertain[other]=nil end
 end
 self.owned[guid]={unit=unit,icon=icon,pullEnded=pullEnded or nil}
end
function M:GroupQuiet()
 if combat()then return false end
 local members=self:Members()
 if #members<=1 and D.Compat.InGroup()then return false end
 for _,unit in ipairs(members)do
  if read(UnitAffectingCombat,unit)~=false then return false end
  local pet=unit=='player'and 'pet'or unit..'pet'
  if read(UnitExists,pet)==true and read(UnitAffectingCombat,pet)~=false then return false end
 end
 return true
end
function M:Confirm(units)
 local byGUID={}
 for _,unit in ipairs(units)do
  local guid=read(UnitGUID,unit)
  if type(guid)=='string'then byGUID[guid]=unit end
 end
 for guid,entry in pairs(self.owned)do
  local unit=byGUID[guid]
  if unit then
   local dead=read(UnitIsDeadOrGhost,unit);local icon,known=read(GetRaidTargetIndex,unit)
   if dead==true or known and icon~=entry.icon then self.owned[guid]=nil else entry.unit=unit end
  end
 end
 -- Reserve ambiguous successful clicks until the server exposes their result.
 for guid,entry in pairs(self.uncertain)do
  local unit=byGUID[guid]
  if unit then
   local icon,known=read(GetRaidTargetIndex,unit)
   if read(UnitIsDeadOrGhost,unit)==true then self.uncertain[guid]=nil
   elseif known then
    if icon==entry.icon then self:RememberMark(guid,unit,icon,entry.pullEnded)end
    self.uncertain[guid]=nil
   end
  end
 end
 local p=self.pending
 if p then
  local unit=byGUID[p.guid]
  if unit and read(GetRaidTargetIndex,unit)==p.icon then
   self:RememberMark(p.guid,unit,p.icon,p.pullEnded);self.pending=nil;self.notice=nil
  elseif stamp()>p.expires then
   self.uncertain[p.guid]={unit=unit,icon=p.icon,pullEnded=p.pullEnded};self.pending=nil;self.notice='Mark was not confirmed. Check permissions or use the game\'s Raid Target keys.'
  end
 end
end
-- Learn only observed NPC casts, never infer a healer from its name.
function M:Cast(unit)
 for _,entry in ipairs({{UnitCastingInfo,8},{UnitChannelInfo,7}})do
  if type(entry[1])=='function'then
   local result={pcall(entry[1],unit)}
   local name=result[1] and D.Compat.Plain(result[2])
   if type(name)=='string'and name~=''then
    local blocked=D.Compat.Plain(result[entry[2]+1])
    return name,blocked==false and 'Interrupt' or blocked==true and 'Cannot interrupt' or 'Interruptibility unknown'
   end
  end
 end
end
function M:ObserveCaster(unit)
 local c=self:Candidate(unit);if not c then return end
 local spell=self:Cast(unit)
 if spell then self:DB().casters[c.npc]=true end
end
function M:Scan()
 local active,why=self:Context();self.plan={};self.status=why
 if not active then
  if combat() and self.combatSnapshot then
   self:Confirm(self:Units());self:CheckClear()
   local spell,hint=self:Cast('target')
   if spell and self:DB().casters then self:ObserveCaster('target')end
   if spell then self.status=self.status..' '..hint..': '..spell..'.'end
   if self.layoutPending then self.status='Marking settings will apply after combat.'
   elseif self.notice then self.status=self.notice
   elseif self.pending then self.status='Waiting for the game to confirm the mark.' end
  end
  return self.plan
 end
 local db=self:DB();local units=self:Units();self:Confirm(units);self:CheckClear()
 if self.pullEndedPending then self:ReleaseFinishedPull()end
 if self.pending then self.status='Waiting for the game to confirm the mark.';return self.plan end
 local members=self:Members();local selected=self:Candidate('target')
 local seed=selected or self:Candidate('mouseover')
 local tankTarget
 for _,u in ipairs(members)do
  if read(UnitGroupRolesAssigned,u)=='TANK'then tankTarget=self:Candidate(u..'target');if tankTarget then break end end
 end
 seed=selected or tankTarget or seed
 local playerPos=world('player');local byGUID,list,reserved,visible={},{},{},{}
 for _,unit in ipairs(units)do
  local icon,known=read(GetRaidTargetIndex,unit);local dead=read(UnitIsDeadOrGhost,unit)
  local guid=read(UnitGUID,unit)
  if type(guid)=='string'then visible[guid]=unit end
  if known and type(icon)=='number'and icon>=1 and icon<=8 and dead~=true then reserved[icon]=guid or true end
  local c=self:Candidate(unit)
  if c and not byGUID[c.guid]then
   local explicit=unit=='target'or unit=='mouseover'or tankTarget and c.guid==tankTarget.guid
   local near=seed and db.nearby and distance(seed.pos,c.pos)
   local fromPlayer=distance(playerPos,c.pos)
   local pack=near and near<=18 and fromPlayer and fromPlayer<=45
   local rule=db.npcRules[c.npc]or {};c.rule=rule
   if not rule.skip and (explicit or pack or self:Engaged(unit,members))then
    c.score=(tonumber(rule.danger)or 0)*1000+(db.priority[c.npc]and 1000 or 0)+(tankTarget and c.guid==tankTarget.guid and 200 or 0)+(seed and c.guid==seed.guid and 50 or 0)
    local spell,hint=self:Cast(unit)
    if spell then db.casters[c.npc]=true;c.castHint=hint..': '..spell end
    if db.casters and db.casters[c.npc] and db.castersPriority~=false then c.score=c.score+120;c.caster=true end
    if spell and db.castersPriority~=false then c.score=c.score+400 end
    local classification=read(UnitClassification,unit)
    if classification=='worldboss'then c.score=c.score+300 elseif classification=='elite'or classification=='rareelite'then c.score=c.score+20 end
    byGUID[c.guid]=c;list[#list+1]=c
   end
  end
 end
 for guid,entry in pairs(self.owned)do reserved[entry.icon]=reserved[entry.icon]or guid end
 for guid,entry in pairs(self.uncertain)do reserved[entry.icon]=reserved[entry.icon]or guid end
 local globalUse={}
 for icon=1,8 do globalUse[icon]=self:IconInUse(icon);if globalUse[icon]and not reserved[icon]then reserved[icon]=true end end
 -- A previous pull's icon may be reused on the NEXT hardware click. Do not
 -- clear the live mark or ownership here. Never reclaim an external mark,
 -- a current-pack pre-pull assignment, or anything while a member is fighting.
 local reusable={}
 if seed and (not seed.icon or seed.icon==7 and self.owned[seed.guid]and self.owned[seed.guid].icon==7) and self:GroupQuiet()then
  for _,ledger in ipairs({self.owned,self.uncertain})do
   for guid,entry in pairs(ledger)do
    if guid~=seed.guid and reserved[entry.icon]==guid then
     local unit=visible[guid]
     local idle=not unit or read(UnitAffectingCombat,unit)==false
     local separation=unit and distance(seed.pos,world(unit))
     local previous=entry.pullEnded or (separation and separation>60 and not byGUID[guid])
     -- An ambiguous old attempt is reusable only after the pull has ended.
     local verifiedOld=unit and read(GetRaidTargetIndex,unit)==entry.icon
     if idle and previous and (ledger==self.owned or entry.pullEnded) and (globalUse[entry.icon]~=true or verifiedOld)then
      reserved[entry.icon]=nil;reusable[entry.icon]=guid
     end
    end
   end
  end
 end
 table.sort(list,function(a,b)if a.score~=b.score then return a.score>b.score end;return a.guid<b.guid end)
 local cc=db.cc and self:CCOptions(members)or {}
 local ccIcons={};for _,rule in ipairs(cc)do ccIcons[rule.icon]=rule end
 local killCount=0
 for _,c in ipairs(list)do
  local promote=c.guid==(seed and seed.guid) and c.icon==7 and self.owned[c.guid] and self.owned[c.guid].icon==7 and reusable[8]
  if not c.icon or promote then
   if promote then c.promoteFrom=c.icon end
   local icon,reason
   local preferred=c.rule.icon
   if type(preferred)=='number'and ICONS[preferred]and not reserved[preferred]then
    local ccRule=ccIcons[preferred];local kind=creature(c.unit)
    if not ccRule or (not c.rule.immune and kind and ccRule.types[kind])then icon=preferred;reason='Personal NPC icon preference'end
   end
   for _,first in ipairs({8,7})do if not icon and not reserved[first]then icon=first;break end end
   if not icon and db.cc and not c.rule.immune then
    local kind=creature(c.unit)
    for _,rule in ipairs(cc)do
     if kind and rule.types[kind]and not reserved[rule.icon]then icon=rule.icon;reason=rule.class..' CC suggestion ('..(read(UnitName,rule.member)or rule.member)..')';break end
    end
   end
   if not icon then for _,spare in ipairs(KILL_ORDER)do if not reserved[spare]and not ccIcons[spare]then icon=spare;break end end end
   if icon then
    reserved[icon]=c.guid;c.icon=icon;c.replaces=reusable[icon]
    c.reason=c.replaces and ('Reuse '..ICONS[icon]..' from the previous pull')or reason or ((tonumber(c.rule.danger)or 0)>=2 and 'Personal high-danger NPC priority')or (c.castHint or c.caster and 'Observed caster: kill priority' or 'Kill priority')
    self.plan[#self.plan+1]=c;killCount=killCount+1
   end
  end
 end
 self.status=self.notice or (#self.plan>0 and why or (#list>0 and 'No free icon, or these mobs are already marked.' or 'Select / hover an unmarked mob. Hidden unit data cannot be planned.'))
 return self.plan
end
function M:Prepare(button)
 -- Called ONLY by a real click/key release, never by the scanning ticker.
 if combat()then
  self.armed=nil
  local icon=self.combatSnapshot
  -- This branch observes only. Secure attributes were fixed before combat.
  -- The state driver requires a living hostile current target and a group.
  if icon and self:DB().combatMode=='fixed' then
   local c=self:Candidate('target')
   if c and c.icon~=icon then c.icon=icon;self.armed=c end
   self.status='Combat: '..ICONS[icon]..' on your current enemy target.'
  elseif icon then self.status='Combat: use the icon buttons below or their individual keybinds.'
  else self.status='Combat marking is off; enable it before the pull.' end
  return
 end
 button:SetAttribute('type',nil);self.armed=nil
 local plan=self:Scan();local c=plan[1]
 if not c then self:Paint();return end
 -- Revalidate immediately: tokens may have changed between a timer tick and the click.
 local current=self:Candidate(c.unit)
 if not current or current.guid~=c.guid then return end
 if current.icon and not(c.promoteFrom==current.icon and self.owned[c.guid]and self.owned[c.guid].icon==current.icon)then return end
 self.armed=c
 button:SetAttribute('unit',c.unit);button:SetAttribute('marker',c.icon)
 button:SetAttribute('action','set');button:SetAttribute('type','raidtarget')
end
function M:PrepareIcon(button,icon)
 self.armed=nil
 if not combat()then
  button:SetAttribute('type',nil)
  local allowed=self:Context();if not allowed then return end
  button:SetAttribute('unit','target');button:SetAttribute('marker',icon)
  button:SetAttribute('action','set');button:SetAttribute('type','raidtarget')
 elseif not self.combatSnapshot then return end
 local c=self:Candidate('target')
 if c and c.icon~=icon then c.icon=icon;self.armed=c end
end
function M:AfterClick(button)
 local c=self.armed;self.armed=nil
 if not combat()then button:SetAttribute('type',nil)else self.disarm=true end
 if c then self.pending={guid=c.guid,icon=c.icon,expires=stamp()+1.5}end
 self:Paint()
end
function M:Paint()
 if not self.frame then return end
 local c=self.plan[1]
 local fixed=combat() and self.combatSnapshot
 self.button.text:SetText(fixed and (self:DB().combatMode=='fixed' and ('Mark target: '..ICONS[fixed])or 'Choose icon below')or(c and 'Mark next: '..ICONS[c.icon]or 'Mark next mob'))
 self.frame.status:SetText(self.status)
 local icon=(fixed and self:DB().combatMode=='fixed' and fixed) or (not fixed and c and c.icon)
 if icon then self.button.icon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..icon);self.button.icon:Show()else self.button.icon:Hide()end
end
local PAGE={key='dudeGroupMarks',title='Group marks · party and raid'}
HP.nativeGroupMarksPage=PAGE
function M:Apply()
 if combat()then self.layoutPending=true;self.status='Marking settings will apply after combat.';self:Paint();return end
 local db=self:DB();if not db then return end
 local enabled=db.enabled and (not HP.Suite or HP.Suite:On('marking'))
 if not self.frame then
  local f=CreateFrame('Frame','DudeDingGroupMarksBar',UIParent,'BackdropTemplate');self.frame=f
  f:SetSize(300,150);f:SetMovable(true);f:SetClampedToScreen(true);f:EnableMouse(true);f:RegisterForDrag('LeftButton')
  f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',tile=false,edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
  f:SetBackdropColor(.025,.022,.015,.92);f:SetBackdropBorderColor(.6,.48,.14,1)
  local pos=D.char.groupMarksPosition
  if type(pos)=='table'and type(pos.x)=='number'and type(pos.y)=='number'then f:SetPoint(pos.point or 'TOP',UIParent,pos.relative or 'TOP',pos.x,pos.y)else f:SetPoint('TOP',UIParent,'TOP',0,-180)end
  f.title=UI.Text(f,'semibold',12,{1,.84,.1,1});f.title:SetPoint('TOPLEFT',10,-8);f.title:SetText('Group marks')
  f.status=UI.Text(f,'regular',10,{.8,.78,.7,1});f.status:SetPoint('BOTTOMLEFT',10,8);f.status:SetWidth(280);f.status:SetHeight(34);f.status:SetJustifyH('LEFT')
  f:SetScript('OnDragStart',function()if not combat()then f:StartMoving()end end)
  f:SetScript('OnDragStop',function()
   if combat()then return end;f:StopMovingOrSizing()
   local point,_,relative,x,y=f:GetPoint();D.char.groupMarksPosition={point=point,relative=relative,x=x,y=y}
  end)
  local b=CreateFrame('Button','DudeDingGroupMarkVisible',f,'SecureActionButtonTemplate,SecureHandlerStateTemplate');self.button=b
  b:SetSize(195,25);b:SetPoint('TOPLEFT',10,-27);b:RegisterForClicks('LeftButtonUp')
  b:SetAttribute('useOnKeyDown',false);b:SetAttribute('type',nil)
  -- Fixed combat action. Mark placement still requires the player's click/key.
  -- The state rule rejects friendly, dead, absent targets and solo play.
  local combatState=[[if newstate == 'combat' and self:GetAttribute('combat-allowed') and self:GetAttribute('combat-fixed') then
   self:SetAttribute('unit', 'target')
   self:SetAttribute('marker', self:GetAttribute('combat-marker'))
   self:SetAttribute('action', 'set')
   self:SetAttribute('type', 'raidtarget')
  else self:SetAttribute('type', nil) end]]
  self.combatState=combatState
  b:SetAttribute('_onstate-combat',combatState)

  local bg=b:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.24,.19,.035,.9)
  b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(17,17);b.icon:SetPoint('LEFT',5,0)
  b.text=UI.Text(b,'semibold',12,{1,.9,.4,1});b.text:SetPoint('CENTER',8,0)
  b:SetScript('PreClick',function(button)M:Prepare(button)end)
  b:SetScript('PostClick',function(button)M:AfterClick(button)end)
  -- The key's secure button is independent of the optional visible bar.
  -- Hiding the bar must not disable its key binding.
  local key=CreateFrame('Button','DudeDingGroupMark',UIParent,'SecureActionButtonTemplate,SecureHandlerStateTemplate');self.keyButton=key
  key:SetSize(1,1);key:SetAlpha(0);key:SetPoint('TOPLEFT',UIParent,'TOPLEFT',-10000,10000);key:EnableMouse(false)
  key:RegisterForClicks('LeftButtonUp');key:SetAttribute('useOnKeyDown',false);key:SetAttribute('type',nil)
  key:SetAttribute('_onstate-combat',self.combatState)
  key:SetScript('PreClick',function(button)M:Prepare(button)end)
  key:SetScript('PostClick',function(button)M:AfterClick(button)end)

  b:SetScript('OnEnter',function()
   if not GameTooltip then return end
   GameTooltip:SetOwner(b,'ANCHOR_BOTTOM');GameTooltip:AddLine('Group marks')
   GameTooltip:AddLine('Before pull: one unmarked mob per press, Skull / Cross / Moon first. Combat: choose an icon below; direct icon clicks intentionally replace that icon. Casters get higher pre-pull priority.',1,.85,.3,true)
   for i,c in ipairs(M.plan)do if i>8 then break end;GameTooltip:AddLine(ICONS[c.icon]..': '..c.name..' - '..c.reason,.85,.85,.85,true)end
   GameTooltip:AddLine('CC icons are suggestions: check learned spells and immunity.',.7,.7,.7,true);GameTooltip:Show()
  end)
  b:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
  self.iconButtons={}
  for index,icon in ipairs(KILL_ORDER)do
   local markIcon=icon
   local direct=CreateFrame('Button','DudeDingMarkIcon'..icon,UIParent,'SecureActionButtonTemplate,SecureHandlerStateTemplate')
   self.iconButtons[index]=direct
   direct:SetSize(25,25);direct:SetPoint('TOPLEFT',f,'TOPLEFT',10+(index-1)*34,-55)
   direct:RegisterForClicks('LeftButtonUp');direct:SetAttribute('useOnKeyDown',false)
   direct:SetAttribute('combat-fixed',true);direct:SetAttribute('combat-marker',icon)
   direct:SetAttribute('_onstate-combat',combatState)
   local tex=direct:CreateTexture(nil,'ARTWORK');tex:SetAllPoints();tex:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..icon)
   direct:SetScript('PreClick',function(button)M:PrepareIcon(button,markIcon)end)
   direct:SetScript('PostClick',function(button)M:AfterClick(button)end)
   direct:SetScript('OnEnter',function()
    if not GameTooltip then return end
    GameTooltip:SetOwner(direct,'ANCHOR_BOTTOM');GameTooltip:AddLine(ICONS[markIcon]..' · current target')
    GameTooltip:AddLine('Direct command: replaces this icon if already assigned. Use Mark next before the pull to preserve existing assignments.',1,.85,.3,true)
    GameTooltip:Show()
   end)
   direct:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
  end

  local clear=CreateFrame('Button','DudeDingClearMarks',UIParent,'SecureActionButtonTemplate,SecureHandlerStateTemplate');self.clearButton=clear
  clear:SetSize(120,23);clear:SetPoint('TOPLEFT',f,'TOPLEFT',10,-84)
  clear:RegisterForClicks('LeftButtonUp');clear:SetAttribute('useOnKeyDown',false)
  clear:SetAttribute('unit','player');clear:SetAttribute('action','clear-all')
  clear:SetAttribute('_onstate-clear',[[if newstate=='active' and self:GetAttribute('clear-allowed') then self:SetAttribute('type','raidtarget')else self:SetAttribute('type',nil)end]])
  local clearBG=clear:CreateTexture(nil,'BACKGROUND');clearBG:SetAllPoints();clearBG:SetColorTexture(.3,.1,.055,.95)
  local clearText=UI.Text(clear,'semibold',11,{1,.9,.5,1});clearText:SetPoint('CENTER');clearText:SetText('Clear ALL marks')
  clear:SetScript('PreClick',function(button)
   if combat()then return end
   button:SetAttribute('type',nil)
   if M:Context()then button:SetAttribute('type','raidtarget')end
  end)
  clear:SetScript('PostClick',function(button)
   if button:GetAttribute('type')~='raidtarget'then return end
   if not combat()then button:SetAttribute('type',nil)end
   M.clearAttempt={expires=stamp()+2};M.notice='Clear requested; checking game marker state.'
   M:CheckClear();M:Scan();M:Paint()
  end)
  clear:SetScript('OnEnter',function()
   if not GameTooltip then return end;GameTooltip:SetOwner(clear,'ANCHOR_BOTTOM');GameTooltip:AddLine('Clear ALL raid marks')
   GameTooltip:AddLine('Explicit group-wide reset, including other players and off-screen marks. Requires group marking permission. No automatic clearing after combat.',1,.8,.3,true);GameTooltip:Show()
  end)
  clear:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
  local options=CreateFrame('Button',nil,f);options:SetSize(72,25);options:SetPoint('TOPRIGHT',-10,-27)
  local o=options:CreateTexture(nil,'BACKGROUND');o:SetAllPoints();o:SetColorTexture(.13,.12,.08,.95)
  local text=UI.Text(options,'regular',11,{1,.9,.5,1});text:SetPoint('CENTER');text:SetText('Settings')
  options:SetScript('OnClick',function()Cfg:Open('automation');Cfg:OpenPage(PAGE)end)
 end
 if not self.driverBound and type(RegisterStateDriver)=='function'then
  local visible=pcall(RegisterStateDriver,self.button,'combat','[combat,group,@target,harm,nodead] combat; peace')
  local bound=pcall(RegisterStateDriver,self.keyButton,'combat','[combat,group,@target,harm,nodead] combat; peace')
  local clearBound=pcall(RegisterStateDriver,self.clearButton,'clear','[group] active; inactive')
  self.driverBound=visible and bound and clearBound
  for _,direct in ipairs(self.iconButtons)do
   local ok=pcall(RegisterStateDriver,direct,'combat','[combat,group,@target,harm,nodead] combat; peace')
   self.driverBound=self.driverBound and ok
  end
 end
 local allowed=self:Context()
 self.combatSnapshot=allowed and db.combatTarget and ICONS[db.combatIcon] and db.combatIcon or nil
 for _,button in ipairs({self.button,self.keyButton})do
  button:SetAttribute('combat-fixed',db.combatMode=='fixed')
  button:SetAttribute('combat-marker',self.combatSnapshot or 8)
  button:SetAttribute('combat-allowed',self.combatSnapshot~=nil)
 end
 for _,direct in ipairs(self.iconButtons)do
  direct:SetAttribute('combat-allowed',self.combatSnapshot~=nil)
  local shown=enabled and db.showBar and D.Compat.InGroup()
  direct:SetAlpha(shown and 1 or 0);direct:EnableMouse(shown)
 end
 self.clearButton:SetAttribute('clear-allowed',allowed==true)
 self.clearButton:SetAlpha(enabled and db.showBar and D.Compat.InGroup()and 1 or 0)
 self.clearButton:EnableMouse(enabled and db.showBar and D.Compat.InGroup())
 self.layoutPending=false
 self.frame:SetShown(enabled and db.showBar and D.Compat.InGroup())
 self:Scan();self:Paint()
end
local function check(canvas,width,key,label,desc)
 return UI.CheckRow(canvas,Cfg,{label=label,desc=desc,default=DEFAULTS[key],get=function()return M:DB()[key]end,set=function(v)M:DB()[key]=v;M:Apply()end},width)
end
PAGE.build=function(canvas,width)
 return {
 UI.InfoRow(canvas,'Before pull: each press marks the next unmarked mob: Skull, Cross, Moon, then remaining free icons. Combat: use the explicit icon buttons/keybinds. Priority planning cannot dynamically change protected combat actions. Settings apply after combat.',width),
 check(canvas,width,'enabled','Enable group mark assistant','Automatically plans icons; you confirm each mob with a click/key.'),
 check(canvas,width,'party','Enable in parties'),check(canvas,width,'raid','Enable in raids','Raid leader or assistant permission is required.'),
 check(canvas,width,'instances','Enable in dungeons and raid instances'),check(canvas,width,'outdoors','Enable while leveling outdoors in a group'),
 check(canvas,width,'leaderOnly','Only group leader / raid assistants','Turn off to mark as a regular party member. Choose one marker per group.'),
 check(canvas,width,'nearby','Include the selected nearby pack','Within 18 yards of the selected/tank target and 45 yards of you, when positions are readable.'),
 check(canvas,width,'castersPriority','Prioritize observed casters','Actively casting/channeling enemies come first; remembers NPC IDs seen casting. Interrupt advice uses the current cast flag when readable.'),
 check(canvas,width,'cc','Suggest crowd control after Skull and Cross','Uses compatible creature type and group class presence; check spell availability and immunity.'),
 check(canvas,width,'showBar','Show movable Group marks bar'),
 check(canvas,width,'combatTarget','Mark my target in combat','Enable the direct icon buttons/keybinds in combat. Requires a living enemy target and a group.'),
 UI.SelectorRow(canvas,Cfg,{label='Combat controls',default='palette',values={{'palette','Direct icon buttons (recommended)'},{'fixed','Legacy single fixed icon'}},get=function()return M:DB().combatMode end,set=function(v)M:DB().combatMode=v;M:Apply()end},width),
 UI.SelectorRow(canvas,Cfg,{label='Legacy fixed combat icon',default=8,
  values={{8,'Skull'},{7,'Cross'},{6,'Square'},{5,'Moon'},{4,'Triangle'},{3,'Diamond'},{2,'Circle'},{1,'Star'}},
  get=function()return M:DB().combatIcon end,set=function(v)M:DB().combatIcon=v;M:Apply()end},width),
 UI.BindingRow(canvas,Cfg,{label='Clear ALL raid marks (including others / off-screen)',action='CLICK DudeDingClearMarks:LeftButton'},width),
 UI.InfoRow(canvas,'NPC rules below apply to the selected readable enemy NPC ID. Automatic means normal planning. CC immunity is a manual flag on Forever; no combat-log learning is assumed.',width),
 UI.SelectorRow(canvas,Cfg,{label='Selected NPC: danger',default=0,values={{0,'Normal / observed caster'},{1,'Elevated'},{2,'High: interrupt priority'},{3,'Critical: healer / summoner'}},get=function()return M:TargetRule().danger or 0 end,set=function(v)M:SetRule('danger',v)end},width),
 UI.SelectorRow(canvas,Cfg,{label='Selected NPC: preferred icon',default=0,values={{0,'Automatic'},{8,'Skull'},{7,'Cross'},{5,'Moon'},{6,'Square'},{4,'Triangle'},{3,'Diamond'},{2,'Circle'},{1,'Star'}},get=function()return M:TargetRule().icon or 0 end,set=function(v)M:SetRule('icon',v)end},width),
 UI.CheckRow(canvas,Cfg,{label='Selected NPC: immune to crowd control',default=false,get=function()return M:TargetRule().immune==true end,set=function(v)M:SetRule('immune',v)end},width),
 UI.CheckRow(canvas,Cfg,{label='Selected NPC: exclude from planning',default=false,get=function()return M:TargetRule().skip==true end,set=function(v)M:SetRule('skip',v)end},width),
 UI.ButtonRow(canvas,Cfg,{label='Selected NPC rules',desc=function()local c=M:Candidate('target');return c and (c.name..' · NPC '..c.npc)or 'Select a readable hostile NPC.'end,button='Forget',run=function()local c=M:Candidate('target');if c then M:DB().npcRules[c.npc]=nil;M:Scan();M:Paint()end end},width),
 UI.BindingRow(canvas,Cfg,{label='Mark next mob before pull (combat: use direct icon binds)',action='CLICK DudeDingGroupMark:LeftButton'},width),
 UI.ButtonRow(canvas,Cfg,{label='Prefer selected NPC as a kill target',desc='Save a priority for this NPC ID. No downloaded danger database is assumed.',button='Remember',run=function()
  local c=M:Candidate('target');if c then M:DB().priority[c.npc]=true;M:Scan();M:Paint();D:Print('Kill priority remembered: '..c.name)else D:Print('Select a readable hostile NPC first.')end
 end},width),
 UI.ButtonRow(canvas,Cfg,{label='Forget selected NPC priority',button='Forget',run=function()local c=M:Candidate('target');if c then M:DB().priority[c.npc]=nil;M:Scan();M:Paint()end end},width),
 UI.ButtonRow(canvas,Cfg,{label='Marking status',desc=function()M:Scan();return M.status end,button='Check',run=function()M:Scan();M:Paint();D:Print(M.status)end},width),
 UI.InfoRow(canvas,'Skull → Cross → Moon → Square → Triangle → Diamond → Circle → Star. Turning on class CC suggestions can change the spare-icon order. CC suggestions: Moon/Mage, Diamond/Rogue, Triangle/Warlock, Star/Priest, Circle/Druid, Square/Hunter. Existing marks are reserved. After a pull ends, your next press can reuse our old icon on a new mob; external marks are kept. Hidden external icons cannot be guaranteed free.',width)}
end
local automation=Cfg.TABS[Cfg.TAB.automation or 3].build
Cfg.TABS[Cfg.TAB.automation or 3].build=function(canvas,width)
 local rows=automation(canvas,width)
 if HP.Suite then return rows end
 table.insert(rows,1,UI.ButtonRow(canvas,Cfg,{label='Group marks · party and raid',desc='Plan Skull, Cross and optional CC icons before a pull.',button='Options',run=function()Cfg:OpenPage(PAGE)end},width))
 table.insert(rows,1,check(canvas,width,'enabled','Enable group mark assistant','Mark key/button: suggested mob before pull; current enemy target in combat.'))
 return rows
end
local bindings=Cfg.TABS[Cfg.TAB.bindings or 5].build
Cfg.TABS[Cfg.TAB.bindings or 5].build=function(canvas,width)
 local rows=bindings(canvas,width)
 rows[#rows+1]=UI.BindingRow(canvas,Cfg,{label='Clear ALL raid marks (including others / off-screen)',action='CLICK DudeDingClearMarks:LeftButton'},width)
 rows[#rows+1]=UI.BindingRow(canvas,Cfg,{label='Mark next mob before pull (combat: use direct icon binds)',action='CLICK DudeDingGroupMark:LeftButton'},width)
 for _,icon in ipairs(KILL_ORDER)do rows[#rows+1]=UI.BindingRow(canvas,Cfg,{label=ICONS[icon]..' on current target',action='CLICK DudeDingMarkIcon'..icon..':LeftButton'},width)end
 return rows
end
_G['BINDING_NAME_CLICK DudeDingClearMarks:LeftButton']='Clear ALL raid marks (including other players)'
for _,icon in ipairs(KILL_ORDER)do _G['BINDING_NAME_CLICK DudeDingMarkIcon'..icon..':LeftButton']=ICONS[icon]..' on current target'end
_G['BINDING_NAME_CLICK DudeDingGroupMark:LeftButton']='Mark next mob before pull (combat: use direct icon binds)'
local command=SlashCmdList.DUDEWHERESMYDING
SlashCmdList.DUDEWHERESMYDING=function(input)
 local sub=(input or ''):lower():match('^%s*marks%s*(.-)%s*$')
 if sub~=nil then
  if sub=='on'or sub=='off'then M:DB().enabled=sub=='on';M:Apply();D:Print('Group mark assistant '..(sub=='on'and 'enabled.'or 'disabled.'))
  elseif sub=='status'then M:Scan();D:Print(M.status)
  else Cfg:Open('automation');Cfg:OpenPage(PAGE)end
  return
 end
 return command(input)
end
-- Retire the old solo automatic marker on the protected Forever client as well.
local mark=D.Compat.MarkTarget
local ok,_,_,_,interface=pcall(GetBuildInfo)
local protected=ok and type(interface)=='number'and interface>=16000 and interface<20000
HP.GroupMarkingProtected=protected
function D.Compat.MarkTarget(icon)if protected then return false end;return mark(icon)end
D:On('PLAYER_LOGIN',function()M:Apply()end)
function M:ReleaseFinishedPull()
 -- Regen can arrive before the last party member/mob has dropped combat.
 -- Retry from Scan, keeping ownership even when the returning mob disappears.
 if not self:GroupQuiet()then return false end
 self.pullEndedPending=nil
 if self.pending then self.pending.pullEnded=true end
 local visible={}
 for _,unit in ipairs(self:Units())do local guid=read(UnitGUID,unit);if type(guid)=='string'then visible[guid]=unit end end
 for _,ledger in ipairs({self.owned,self.uncertain})do
  for guid,entry in pairs(ledger)do
   local unit=visible[guid]
   if not unit or read(UnitAffectingCombat,unit)==false then
    entry.pullEnded=true
   else self.pullEndedPending=true end
  end
 end
 return true
end
for _,event in ipairs({'UNIT_SPELLCAST_START','UNIT_SPELLCAST_CHANNEL_START'})do D:On(event,function(_,unit)M:ObserveCaster(unit);M:Scan();M:Paint()end)end
D:On('UNIT_HEALTH',function(_,unit)
 local guid=read(UnitGUID,unit)
 if type(guid)=='string'and (M.owned[guid]or M.uncertain[guid])and read(UnitIsDeadOrGhost,unit)==true then M.owned[guid]=nil;M.uncertain[guid]=nil end
end)
D:On('PLAYER_REGEN_ENABLED',function()
 M.pullEndedPending=true;M:ReleaseFinishedPull()
 if M.button then M.button:SetAttribute('type',nil)end
 if M.keyButton then M.keyButton:SetAttribute('type',nil)end
 M.disarm=nil;M:Apply()
end)
D:On('PLAYER_REGEN_DISABLED',function()M.pullEndedPending=nil;M.armed=nil;M:Scan();M:Paint()end)
D:On('GROUP_ROSTER_UPDATE',function()M:Apply()end)
D:On('RAID_TARGET_UPDATE',function()M:Scan();M:Paint()end)
D:On('PLAYER_TARGET_CHANGED',function()M:Scan();M:Paint()end)
D:On('PLAYER_ENTERING_WORLD',function()M.owned={};M.uncertain={};M.pending=nil;M.notice=nil;M.pullEndedPending=nil;M.clearAttempt=nil;M:Apply()end)
local ticker=CreateFrame('Frame');M.ticker=ticker;local elapsed=0
ticker:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<.5 then return end;elapsed=0
 if not D.db then return end
 local db=M:DB()
 if db.enabled then M:Scan();M:Paint()end
end)

local arrows=Cfg.TABS[Cfg.TAB.arrow or 4].build
Cfg.TABS[Cfg.TAB.arrow or 4].build=function(canvas,width)
 local rows=arrows(canvas,width)
 if protected then
  for i=#rows,1,-1 do
   local row=rows[i]
   if row.opts and row.opts.label==D.L.MARK_TARGET or row.header and row.label and row.label:GetText()==D.L.HEADER_TARGET then row:Hide();table.remove(rows,i)end
  end
 end
 return rows
end

end)
