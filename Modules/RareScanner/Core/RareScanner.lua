local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'rares',function(...)
-- Rare sightings from public game events. Independently implemented; no external addon dependency.
local _,HP=...
local D=HP.Native
local R={records={},order={},seen={},status='Disabled',serial=0};HP.Rares=R
local DEFAULTS={followTheme=true,enabled=false,npcs=true,treasures=true,events=false,items=false,models=true,sound=true,soundID=8959,locked=false,scale=100,opacity=92,duration=45,cooldown=180,combat=true}
local function read(fn,...)
 if type(fn)~='function'then return nil,false end
 local ok,value=pcall(fn,...);if not ok then return nil,false end
 if type(issecretvalue)=='function'then local good,secret=pcall(issecretvalue,value);if not good or secret then return nil,false end end
 return value,true
end
R.Read=read
function R:Now()return read(GetTime)or 0 end
function R:DB()
 if not D.db then return end
 D.db.ui.rares=D.db.ui.rares or {};local cfg=D.db.ui.rares
 for k,v in pairs(DEFAULTS)do if cfg[k]==nil then cfg[k]=v end end
 cfg.ignore=cfg.ignore or {};cfg.displays=cfg.displays or {};return cfg
end
function R:Field(obj,key)
 if obj==nil then return end
 return read(function()return obj[key]end)
end
function R:ID(guid)
 if type(guid)~='string'then return end
 local kind,id=guid:match('^([^-]+)%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)%-')
 if kind=='Creature'or kind=='Vehicle'or kind=='GameObject'then return tonumber(id),kind end
end
function R:Map()return read(C_Map and C_Map.GetBestMapForUnit,'player')end
function R:Point(map,pos,label)
 if type(map)~='number'or pos==nil then return end
 local ok,x,y=pcall(function()return pos:GetXY()end)
 if not ok then x,y=self:Field(pos,'x'),self:Field(pos,'y')end
 x,y=D.Compat.Plain(x),D.Compat.Plain(y)
 if type(x)=='number'and type(y)=='number'and x==x and y==y and x>=0 and x<=1 and y>=0 and y<=1 then return {map=map,x=x*100,y=y*100,label=label,dudeRare=true}end
end
function R:UnitPoint(unit,label)
 if type(UnitPosition)~='function'or not C_Map or type(C_Map.GetMapPosFromWorldPos)~='function'or type(CreateVector2D)~='function'then return end
 local ok,x,y,_,instance=pcall(UnitPosition,unit);if not ok then return end
 x,y,instance=D.Compat.Plain(x),D.Compat.Plain(y),D.Compat.Plain(instance)
 if type(x)~='number'or type(y)~='number'or type(instance)~='number'then return end
 local good,map,pos=pcall(C_Map.GetMapPosFromWorldPos,instance,CreateVector2D(x,y),self:Map())
 if good then return self:Point(D.Compat.Plain(map),pos,label)end
end
function R:Allowed(kind)
 if HP.Suite and not HP.Suite:On('rares') then return false end
 local cfg=self:DB();if not cfg or not cfg.enabled then return false end
 if not cfg.combat and read(InCombatLockdown)==true then return false end
 return kind=='npc'and cfg.npcs or kind=='treasure'and cfg.treasures or kind=='event'and cfg.events or kind=='item'and cfg.items or false
end
function R:Alert(entry)
 local cfg=self:DB();if not cfg or not self:Allowed(entry.kind)then return end
 if type(entry.key)~='string'or type(entry.name)~='string'or cfg.ignore[entry.identity]then return end
 local t=self:Now();entry.last=t
 local old=self.records[entry.key]
 if old then
  local oldPoint=old.point;local enriched=entry.unit and (not old.unit or read(UnitGUID,old.unit)~=old.guid)
  for _,key in ipairs({'unit','point','vignette','link','icon','displayID'})do if entry[key]~=nil then old[key]=entry[key]end end
  old.last=t
  if self.tracked==entry.key and self.rareFocus and D.Arrow.forced==self.rareFocus and old.point and (not oldPoint or oldPoint.map~=old.point.map or math.abs(oldPoint.x-old.point.x)>.01 or math.abs(oldPoint.y-old.point.y)>.01)then
   self.rareFocus.points[1]=old.point;D.Arrow.point=nil;D.Arrow.farm=nil
  end
  if enriched and self.current==entry.key and self.Render then self:Render(true)end
  return old
 end
 local seen=self.seen[entry.key]
 if seen and t-seen<cfg.cooldown then return end
 self.seen[entry.key]=t;
 local count,oldest,oldTime=0,nil,t
 for key,at in pairs(self.seen)do count=count+1;if not oldest or at<oldTime then oldest,oldTime=key,at end end
 if count>512 and oldest then self.seen[oldest]=nil end;entry.created=t;self.records[entry.key]=entry;self.order[#self.order+1]=entry.key
 while #self.order>12 do self:Remove(self.order[1])end
 if not self.current or not self.records[self.current]then self.current=entry.key end
 if D.char then
  D.char.rareHistory=D.char.rareHistory or {};local h=D.char.rareHistory
  h[#h+1]={name=entry.name,kind=entry.kind,id=entry.id,time=read(GetServerTime)or read(time),map=entry.point and entry.point.map}
  while #h>50 do table.remove(h,1)end
 end
 if cfg.sound and (not self.lastSound or t-self.lastSound>=2)then
  local played=read(PlaySound,cfg.soundID,'Master');if played~=false then self.lastSound=t end
 end
 self.status='Detected: '..entry.name
 if self.Render then self:Render()end
 return entry
end
function R:Remove(key)
 if not key then return end
 self.records[key]=nil
 for i=#self.order,1,-1 do if self.order[i]==key then table.remove(self.order,i)end end
 if self.tracked==key and self.Stop then self:Stop()end
 if self.current==key then self.current=self.order[1]end
 if self.Render then self:Render()end
end
function R:IgnoreCurrent()
 local e=self.records[self.current];if not e or e.preview then return end
 self:DB().ignore[e.identity]=true
 local list={};for key,r in pairs(self.records)do if r.identity==e.identity then list[#list+1]=key end end
 for _,key in ipairs(list)do self:Remove(key)end
end
function R:ScanUnit(unit)
 local cfg=self:DB();if not cfg or not cfg.enabled or not unit then return end
 if read(UnitExists,unit)~=true or read(UnitIsPlayer,unit)==true or read(UnitPlayerControlled,unit)==true or read(UnitIsDeadOrGhost,unit)==true then return end
 local guid=read(UnitGUID,unit);local id,kind=self:ID(guid)
 if not id or (kind~='Creature'and kind~='Vehicle')then return end
 local classification=read(UnitClassification,unit);local info
 if D.Data and D.Data.NpcInfo then info=read(D.Data.NpcInfo,D.Data,id)end
 local rank=info and self:Field(info,'rank')
 if classification~='rare'and classification~='rareelite'and rank~=2 and rank~=4 then return end
 local name=read(UnitName,unit);if type(name)~='string'or name==''then return end
 self:Alert({key=guid,identity='npc:'..id,id=id,guid=guid,kind='npc',unit=unit,name=name,source='Visible rare',point=self:UnitPoint(unit,name)})
end
function R:ScanVignette(guid,onMinimap)
 guid,onMinimap=D.Compat.Plain(guid),D.Compat.Plain(onMinimap)
 local cfg=self:DB();if not cfg or not cfg.enabled or type(guid)~='string'then return end
 local info,known=read(C_VignetteInfo and C_VignetteInfo.GetVignetteInfo,guid)
 if not info then
  if known then for key,e in pairs(self.records)do if e.vignette==guid then self:Remove(key)end end end
  return
 end
 if self:Field(info,'isDead')==true then for key,e in pairs(self.records)do if e.vignette==guid then self:Remove(key)end end;return end
 if onMinimap==false or self:Field(info,'onMinimap')~=true or self:Field(info,'inFogOfWar')==true then return end
 local atlas=self:Field(info,'atlasName');local name=self:Field(info,'name')
 if type(atlas)~='string'or type(name)~='string'then return end
 local kind
 if atlas:find('VignetteLoot',1,true)or atlas:find('VignetteChest',1,true)then kind='treasure'
 elseif atlas:find('VignetteKill',1,true)then kind='npc'
 elseif atlas:find('VignetteEvent',1,true)then kind='event'else return end
 local object=self:Field(info,'objectGUID');local id,objectKind=self:ID(object)
 if kind=='npc'and objectKind=='GameObject'then kind='treasure'end
 local vid=self:Field(info,'vignetteID');local identity=kind..':'..tostring(id or vid or guid)
 local point=self:Point(self:Map(),read(C_VignetteInfo.GetVignettePosition,guid,self:Map()),name)
 self:Alert({key=id and object or guid,identity=identity,id=id,kind=kind,name=name,guid=object,vignette=guid,point=point,source='Nearby minimap sighting'})
end
function R:Scan()
 local cfg=self:DB();if not cfg or not cfg.enabled then return end
 self.status='Scanning visible rares and nearby minimap sightings'
 local v=read(C_VignetteInfo and C_VignetteInfo.GetVignettes)
 if type(v)=='table'then for _,guid in ipairs(v)do self:ScanVignette(guid)end end
 self:ScanUnit('target');self:ScanUnit('mouseover')
 local list=read(C_NamePlate and C_NamePlate.GetNamePlates)
 if type(list)=='table'then for _,plate in ipairs(list)do self:ScanUnit(self:Field(plate,'namePlateUnitToken'))end end
end
function R:Loot(message)
 if not self:Allowed('item')or type(message)~='string'then return end
 local own=false
 for _,format in ipairs({LOOT_ITEM_SELF or '',LOOT_ITEM_SELF_MULTIPLE or '',LOOT_ITEM_PUSHED_SELF or '',LOOT_ITEM_PUSHED_SELF_MULTIPLE or ''})do
  local prefix=format:match('^(.-)%%s')
  if prefix and #prefix>0 and message:sub(1,#prefix)==prefix then own=true;break end
 end
 if not own then return end
 local link=message:match('(|c%x%x%x%x%x%x%x%x|Hitem:.-|h.-|h|r)')or message:match('(|Hitem:.-|h.-|h)')
 if not link then return end
 local id=tonumber(link:match('item:(%d+)'));if not id then return end
 return self:LootItem(link,id)
end
function R:LootItem(link,id)
 if not self:Allowed('item')then return end
 local getter=C_Item and C_Item.GetItemInfo or GetItemInfo
 if type(getter)~='function'then return end
 local result={pcall(getter,link)};if not result[1]then return end
 local name,quality=D.Compat.Plain(result[2]),D.Compat.Plain(result[4])
 self.pendingItems=self.pendingItems or {}
 if type(name)~='string'or type(quality)~='number'then
  if not self.pendingItems[id]then
   local count=0;for _ in pairs(self.pendingItems)do count=count+1 end
   if count<16 then self.pendingItems[id]={link=link,at=self:Now()};read(C_Item and C_Item.RequestLoadItemDataByID,id)end
  end
  return
 end
 self.pendingItems[id]=nil
 if quality<3 then return end
 local equip=D.Compat.Plain(result[10]);local icon=D.Compat.Plain(result[11])
 self:Alert({key='item:'..id,identity='item:'..id,id=id,kind='item',name=name,link=link,icon=icon,equip=equip,source=quality>=4 and 'Epic loot received'or 'Rare loot received'})
end
function R:Tick()
 local cfg=self:DB();if not cfg or not cfg.enabled then return end
 local expired={};local t=self:Now()
 for id,entry in pairs(self.pendingItems or {})do if t-entry.at>30 then self.pendingItems[id]=nil end end
 for key,e in pairs(self.records)do
  local dead=e.unit and read(UnitGUID,e.unit)==e.guid and read(UnitIsDeadOrGhost,e.unit)==true
  if dead or t-e.created>cfg.duration then expired[#expired+1]=key end
 end
 for _,key in ipairs(expired)do self:Remove(key)end
 if self.modelPending and self.CheckModel then self:CheckModel()end
end
local driver=CreateFrame('Frame');R.driver=driver;local elapsed=0
-- Bounded 1-second polling complements events; no screen/pixel or combat-log scanner.
driver:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<1 then return end;elapsed=0
 if not D.db then return end
 D:Safe(function()R:Scan();R:Tick()end)
end)
for _,event in ipairs({'NAME_PLATE_UNIT_ADDED','UPDATE_MOUSEOVER_UNIT','PLAYER_TARGET_CHANGED','SOFT_ENEMY_CHANGED','SOFT_INTERACT_CHANGED'})do
 D:On(event,function(_,unit)if event=='NAME_PLATE_UNIT_ADDED'then R:ScanUnit(unit)elseif event=='UPDATE_MOUSEOVER_UNIT'then R:ScanUnit('mouseover')elseif event=='SOFT_ENEMY_CHANGED'then R:ScanUnit('softenemy')elseif event=='SOFT_INTERACT_CHANGED'then R:ScanUnit('softinteract')else R:ScanUnit('target')end end)
end
D:On('VIGNETTE_MINIMAP_UPDATED',function(_,guid,on)R:ScanVignette(guid,on)end)
D:On('VIGNETTES_UPDATED',function()R:Scan()end)
D:On('CHAT_MSG_LOOT',function(_,message)R:Loot(D.Compat.Plain(message))end)
D:On('UNIT_HEALTH',function(_,unit)
 if not HP.Public(unit)or type(unit)~='string'then return end
 local dead=read(UnitIsDeadOrGhost,unit);if dead~=true then return end
 local guid=read(UnitGUID,unit);if not guid then return end
 local keys={};for key,e in pairs(R.records)do if e.guid==guid then keys[#keys+1]=key end end
 for _,key in ipairs(keys)do R:Remove(key)end
end)
D:On('NAME_PLATE_UNIT_REMOVED',function(_,unit)for _,e in pairs(R.records)do if e.unit==unit then e.unit=nil end end end)
D:On('ZONE_CHANGED_NEW_AREA',function()local keys={};for key in pairs(R.records)do keys[#keys+1]=key end;for _,key in ipairs(keys)do R:Remove(key)end;R:Scan()end)

for _,event in ipairs({'GET_ITEM_INFO_RECEIVED','ITEM_DATA_LOAD_RESULT'})do D:On(event,function(_,id,success)
 id,success=D.Compat.Plain(id),D.Compat.Plain(success)
 local entry=id and R.pendingItems and R.pendingItems[id]
 if entry then if success==false then R.pendingItems[id]=nil else R:LootItem(entry.link,id)end end
end)end

end)
