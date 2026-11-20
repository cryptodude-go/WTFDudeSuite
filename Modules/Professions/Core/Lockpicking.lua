local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(30,'professions',function(...)
-- Skill-driven Rogue guide and world-anchored footlocker/chest history.
local _,HP=...
local D=HP.Native;local UI,Cfg=D.UI,D.Config
local L={seeds={},worlds={},visited={},revision=0};HP.Lockpicking=L
local FACTS={
 [123330]={min=1,gray=100},[178244]={min=1,gray=100},
 [179486]={min=70,gray=170},[179487]={min=70,gray=170},
 [179488]={min=110,gray=210},[179489]={min=110,gray=210},
 [179490]={min=150,gray=250},[179491]={min=150,gray=250},
 [179492]={min=175,gray=275},[179493]={min=175,gray=275},
 -- Conservatively use 225 for the higher/mixed Slag Pit and Lost Rigger tiers.
 [179494]={min=225,gray=300},[179496]={min=225,gray=300},[179498]={min=250,gray=350},
}
L.facts=FACTS
local BANDS={
 {from=1,to=70,ids={123330,178244},maps={1413,1433}},
 {from=70,to=110,ids={179486,179487},maps={1442,1440,1437,1433,1424}},
 {from=110,to=150,ids={179488,179489},maps={1424,1442,1437,1440}},
 {from=150,to=175,ids={179490,179491},maps={1418,1443}},
 {from=175,to=225,ids={179492,179493},maps={1435,1418}},
 {from=225,to=250,ids={179494,179496},maps={1427,1446}},
 {from=250,to=300,ids={179498},maps={1423}},
}
local book={name='Lockpicking',skillID=633,spellID=1809,steps=BANDS,lockpicking=true}
HP.professionBooks.Lockpicking=book
local function clock()return HP.Call(GetTime)or 0 end
local function stamp()return HP.Call(GetServerTime)or HP.Call(time)or 0 end
local function number(n)return HP.Public(n)and type(n)=='number'and n==n and n>=0 and n<1000000 end
local function valid(p)return p and number(p.mapID)and p.mapID>0 and number(p.x)and number(p.y)and p.x>0 and p.x<1 and p.y>0 and p.y<1 end
local DB_DEFAULTS={enabled=true,record=true,circles=true,known=true,minimap=true,world=true,zone='auto'}
function L:DB()
 if not HP.db then return end
 HP.db.lockpicking=HP.db.lockpicking or {};local db=HP.db.lockpicking
 for k,v in pairs(DB_DEFAULTS)do if db[k]==nil then db[k]=v end end
 db.chests=db.chests or {};return db
end
function L:Enabled()
 local db=self:DB();return db and db.enabled and D.Compat.PlayerClass()=='ROGUE'and HP.Suite:On('professions')
end
function L:Skill()
 local skill=HP.ProfessionSkills()[633]
 if skill then local maximum=number(skill.maximum)and skill.maximum>0 and skill.maximum or math.max(0,HP.Call(UnitLevel,'player')or 0)*5;return skill.rank,math.min(300,maximum),true end
 return 0,math.min(300,math.max(0,HP.Call(UnitLevel,'player')or 0)*5),false
end
local function distance(a,b)
 if not a or not b or a.mapID~=b.mapID then return math.huge end
 local w,h=HP.Call(C_Map and C_Map.GetMapWorldSize,a.mapID)
 w=number(w)and w>0 and w or 5000;h=number(h)and h>0 and h or 3333
 return ((a.x-b.x)*w)^2+((a.y-b.y)*h)^2
end
local function pointKey(p)return p.mapID..':'..p.id..':'..math.floor(p.x*10000)..':'..math.floor(p.y*10000)end
function L:Seeds(map)
 if not self.seeds[map]then
  local list={};for id,fact in pairs(FACTS)do
   for _,p in ipairs(D.Data:ObjectPoints(id))do
    if p.map==map and not p.dungeon and number(p.x)and number(p.y)then
     list[#list+1]={mapID=map,x=p.x/100,y=p.y/100,id=id,min=fact.min,gray=fact.gray,name=D.Data:ObjectName(id)or 'Footlocker',source='Known possible spawn'}
    end
   end
  end
  table.sort(list,function(a,b)if a.id~=b.id then return a.id<b.id end;if a.x~=b.x then return a.x<b.x end;return a.y<b.y end)
  self.seeds[map]=list
 end
 return self.seeds[map]
end
function L:Nodes(map,rank,ids)
 if not number(map)then return {}end
 local out={};local db=self:DB();if not db then return out end
 local cacheKey=tostring(map)..':'..self.revision..':'..tostring(db.known)
 self.nodeCache=self.nodeCache or {}
 local cached=self.nodeCache[map]
 if not rank and not ids and cached and cached.key==cacheKey then return cached.nodes end
 local function allowed(p)return not rank or p.min and p.min<=rank and rank<(p.gray or 350)and(not ids or ids[p.id])end
 if db.known then for _,p in ipairs(self:Seeds(map))do if allowed(p)then out[#out+1]=p end end end
 for _,p in ipairs(db.chests[map]or {})do
  if allowed(p)then
   local replaced=false;for i,n in ipairs(out)do if n.id==p.id and distance(n,p)<20^2 then out[i]=p;replaced=true;break end end
   if not replaced then out[#out+1]=p end
  end
 end
 if not rank and not ids then self.nodeCache[map]={key=cacheKey,nodes=out}end
 return out
end
function L:Record(id,pos,name,source)
 if not self:Enabled()or not self:DB().record or not valid(pos)or not number(id)then return false end
 local db=self:DB();local list=db.chests[pos.mapID]or {};db.chests[pos.mapID]=list
 local fact=FACTS[id];local p
 for _,old in ipairs(list)do if old.id==id and distance(old,pos)<20^2 then p=old;break end end
 if not p then
  p={id=id,mapID=pos.mapID,x=pos.x,y=pos.y,name=name or D.Data:ObjectName(id)or 'Chest',min=fact and fact.min,gray=fact and fact.gray,observed=true,source=source or 'Opened near here',first=stamp(),hits=0}
  list[#list+1]=p
 end
 if not p.last or stamp()-p.last>=3 then p.hits=p.hits+1 end
 p.last=stamp();self.visited[pointKey(p)]=clock()+600
 if #list>500 then table.remove(list,1)end
 local maps={};for map in pairs(db.chests)do maps[#maps+1]=map end;table.sort(maps)
 if #maps>100 then for _,map in ipairs(maps)do if map~=pos.mapID then db.chests[map]=nil;break end end end
 if HP.db.guideBook=='professions'and HP.db.professionGuide=='Lockpicking'and HP.manualWaypoint and distance(HP.manualWaypoint,pos)<20^2 then HP.manualWaypoint=nil end
 self.revision=self.revision+1;return true
end
function L:Task()
 local rank,cap,learned=self:Skill()
 local task={book=book,rank=rank,maximum=cap,rows={},percent=math.min(1,rank/300),index=1}
 if D.Compat.PlayerClass()~='ROGUE'then task.training=true;task.rows={{kind='info',text='Lockpicking is a Rogue skill.'}};return task end
 if not self:Enabled()then task.training=true;task.rows={{kind='info',text='Enable Lockpicking in Professions settings.'}};return task end
 if not learned then task.training=true;task.rows={{kind='info',text='Learn Pick Lock from your Rogue trainer.',tooltipText='The Classic training chain starts at level 16. Bring Thieves’ Tools; use the live client requirement if Forever changes it.'}};return task end
 if rank>=300 then task.complete=true;task.percent=1;task.rows={{kind='info',text='Lockpicking reached 300.'}};return task end
 if rank>=cap then task.training=true;task.rows={{kind='info',text='Level up to raise your Lockpicking cap.',tooltipText='Current live cap: '..cap..'. Lockpicking uses a character-level cap, not Journeyman/Expert profession ranks.'}};return task end
 local band
 for i,b in ipairs(BANDS)do if rank<b.to then band=b;task.index=i;break end end
 task.step={from=band.from,to=band.to,lockpicking=true};local ids={};for _,id in ipairs(band.ids)do ids[id]=true end
 local map=self:DB().zone;local current=HP.GatherCurrentMap()
 if map=='auto'then
  map=current or band.maps[1]
  if #self:Nodes(map,rank,ids)==0 then
   if rank<70 then map=HP.Call(UnitFactionGroup,'player')=='Alliance'and 1433 or 1413
   else for _,candidate in ipairs(band.maps)do if #self:Nodes(candidate,rank,ids)>0 then map=candidate;break end end end
  end
 end
 local nodes=self:Nodes(map,rank,ids)
 if #nodes==0 and self:DB().zone~='auto'then nodes=self:Nodes(map,rank)end
 local here=HP.GatherPosition(map);local best,bestD
 for _,p in ipairs(nodes)do
  local untilAt=self.visited[pointKey(p)]
  local recent=p.observed and p.last and stamp()-p.last>=0 and stamp()-p.last<600
  if (not untilAt or untilAt<=clock())and not recent then
   local d=here and distance(here,p)or 0
   if not best or d<bestD then best,bestD=p,d end
  end
 end
 if best then task.location={mapID=map,x=best.x,y=best.y};task.lockNode=best end
 local info=HP.Call(C_Map and C_Map.GetMapInfo,map);local zone=info and info.name or ('Zone '..tostring(map))
 local name=best and best.name or D.Data:ObjectName(band.ids[1])or 'Footlockers'
 task.rows={{kind='travel',text='Go to '..zone..'.',tooltipText='Known spawns are possible locations, not live detections. Caves, underwater routes and hostile camps may require detours.'},
 {kind='objective',text='Pick '..name..' until skill '..math.min(band.to,cap)..'.',tooltipText='Live skill gains advance the guide. Yellow/green locks may not grant a point. Carry Thieves’ Tools. Next skips a checked location; it does not mark a lock opened.'}}
 if not best then task.location=nil;task.rows={{kind='info',text=#nodes>0 and 'Nearby boxes recently checked. Try again shortly.'or 'No suitable boxes in the selected zone. Choose Automatic or another zone.'}}end
 return task
end
local profession=HP.ProfessionTask
function HP.ProfessionTask(name)if name=='Lockpicking'then if not HP.Suite:ProfessionAllowed(name)then return end;return L:Task()end;return profession(name)end
local move=HP.MoveGatherStep
function HP.MoveGatherStep(delta)
 if HP.db and HP.db.professionGuide=='Lockpicking'then
  HP.manualWaypoint=nil
  local t=HP.auxTask;local p=t and t.lockNode
  if delta<0 and L.lastSkipped then L.visited[L.lastSkipped]=nil;L.lastSkipped=nil
  elseif p then L.lastSkipped=pointKey(p);L.visited[L.lastSkipped]=clock()+180 end
  return
 end
 return move(delta)
end
local function candidate(unit)
 local guid=HP.Call(UnitGUID,unit);if type(guid)~='string'then return end
 local id,kind=HP.Rares:ID(guid);if kind~='GameObject'or not id then return end
 local name=HP.Call(UnitName,unit)or D.Data:ObjectName(id)
 local lower=type(name)=='string'and name:lower()or ''
 if not FACTS[id]and not lower:find('chest',1,true)and not lower:find('footlocker',1,true)and not lower:find('strongbox',1,true)and not lower:find('coffer',1,true)then return end
 local exact=HP.Rares:UnitPoint(unit,name)
 local pos=exact and {mapID=exact.map,x=exact.x/100,y=exact.y/100}or HP.GatherPosition()
 if valid(pos)then return {id=id,name=name,pos=pos,guid=guid,at=clock(),source=exact and 'Opened object position'or 'Opened near here'}end
end
function L:OnEvent(event,unit,a,b,c)
 if not HP.Public(unit)or not HP.Public(a)or not HP.Public(b)or not HP.Public(c)then return end
 if not self:Enabled()then self.pending=nil;return end
 if event=='SKILL_LINES_CHANGED'or event=='CHAT_MSG_SKILL'or event=='PLAYER_LEVEL_UP'then HP.profSkillCache=nil;if HP.db.professionGuide=='Lockpicking'then HP.Refresh()end;return end
 if event=='UNIT_SPELLCAST_SENT'then
  if unit=='player'and c==1804 then
   self.pending=candidate('softinteract')or candidate('mouseover')
   local p=self.pending
   if p and type(a)=='string' and type(p.name)=='string' and UI.StripColors(a):lower()==p.name:lower()then p.cast=b else self.pending=nil end
  elseif unit=='player'then self.pending=nil end
 elseif event=='UNIT_SPELLCAST_SUCCEEDED'then
  if unit=='player'and b==1804 and self.pending and clock()-self.pending.at<15 and (not self.pending.cast or self.pending.cast==a)then
   local p=self.pending;self:Record(p.id,p.pos,p.name,p.source);self.pending=nil;HP.profSkillCache=nil;HP.Refresh()
  end
 elseif event=='UNIT_SPELLCAST_FAILED'or event=='UNIT_SPELLCAST_INTERRUPTED'then if unit=='player'then self.pending=nil end
 elseif event=='LOOT_OPENED'or event=='LOOT_READY'then
  local recorded=false
  for slot=1,math.min(32,HP.Call(GetNumLootItems)or 0)do
   local sources={HP.Call(GetLootSourceInfo,slot)}
   for i=1,#sources,2 do
    local id,kind;if HP.Public(sources[i])then id,kind=HP.Rares:ID(sources[i])end
    local name=id and D.Data:ObjectName(id);local lower=type(name)=='string'and name:lower()or ''
    if kind=='GameObject'and (FACTS[id]or lower:find('chest',1,true)or lower:find('coffer',1,true)or lower:find('strongbox',1,true))then
     local p=HP.GatherPosition();if p then recorded=self:Record(id,p,name,'Looted near here')or recorded end
    end
   end
  end
  if recorded and HP.db.guideBook=='professions'and HP.db.professionGuide=='Lockpicking'then HP.Refresh()end
 else self.pending=nil end
end
function L:Draw(frame,map,project,limit)
 frame.nodes=frame.nodes or {};for _,b in ipairs(frame.nodes)do b:Hide()end
 local rank=self:Skill();local count=0
 for _,p in ipairs(self:Nodes(map))do
  local x,y=project(p)
  if x and y then count=count+1;if count>(limit or 500) then break end
   local b=frame.nodes[count]
   if not b then
    b=CreateFrame('Button',nil,frame);frame.nodes[count]=b;b:SetSize(13,13)
    b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetAllPoints();b.icon:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\PortraitRing')
    b:SetScript('OnEnter',function(self)
     if not GameTooltip then return end
     GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(self.node.name)
     GameTooltip:AddLine(self.node.source..' · possible location',.8,.8,.7,true)
     GameTooltip:AddLine(self.node.min and ('Lockpicking '..self.node.min..' required')or 'Skill requirement unknown',1,.8,.3)
     GameTooltip:AddLine('Click to navigate. A circle does not mean the chest has respawned.',.8,.8,.8,true);GameTooltip:Show()
    end)
    b:SetScript('OnLeave',function()GameTooltip:Hide()end)
    b:SetScript('OnClick',function(self)HP.manualWaypoint={mapID=self.node.mapID,x=self.node.x,y=self.node.y};HP.Refresh()end)
   end
   b.node=p;b:ClearAllPoints();b:SetPoint('CENTER',frame,'TOPLEFT',x,y)
   if p.min and rank<p.min then b.icon:SetVertexColor(1,.25,.2,1)
   elseif p.observed then b.icon:SetVertexColor(.25,1,.4,1)else b.icon:SetVertexColor(1,.76,.15,1)end
   b:Show()
  end
 end
end
function L:UpdateMaps(onlyMini)
 if self.mini then self.mini:Hide()end
 if not onlyMini then for _,f in pairs(self.worlds)do f:Hide()end end
 if not self:Enabled()or not self:DB().circles or HP.db.hidden or HP.db.paused then for _,f in pairs(self.worlds)do f:Hide()end;return end
 local db=self:DB()
 if not onlyMini and db.world and WorldMapFrame and WorldMapFrame:IsShown()then
  local map=HP.Call(WorldMapFrame.GetMapID,WorldMapFrame);local canvas=HP.MapCanvas(WorldMapFrame)
  if map and canvas then
   local f=self.worlds[canvas];if not f then f=CreateFrame('Frame',nil,canvas);f:SetAllPoints(canvas);f:SetFrameLevel(canvas:GetFrameLevel()+23);self.worlds[canvas]=f end
   self:Draw(f,map,function(p)return p.x*canvas:GetWidth(),-p.y*canvas:GetHeight()end);f:Show()
  end
 end
 if db.minimap and Minimap and Minimap:IsShown()then
  if not self.mini then self.mini=CreateFrame('Frame',nil,Minimap);self.mini:SetAllPoints(Minimap);self.mini:SetFrameLevel(Minimap:GetFrameLevel()+23)end
  local map=HP.GatherCurrentMap();local w,h=Minimap:GetWidth(),Minimap:GetHeight();local radius=HP.GatherMinimapRadius();local vector=HP.GatherMinimapVector()
  local angle=HP.Call(GetCVar,'rotateMinimap')=='1'and(HP.Call(GetPlayerFacing)or 0)or 0
  self:Draw(self.mini,map,function(p)
   local dx,dy=vector(p);if not dx then return end
   local x=(dx*math.cos(angle)+dy*math.sin(angle))/radius*w/2;local y=(dy*math.cos(angle)-dx*math.sin(angle))/radius*h/2
   if x*x+y*y<math.max(0,math.min(w,h)*.47-7)^2 then return w/2+x,-h/2+y end
  end,120);self.mini:Show()
 end
end
local page={key='suite-lockpicking',title='Lockpicking · guide & chest circles'};L.page=page
page.build=function(canvas,width)
 local db=L:DB();local rows={}
 for _,v in ipairs({{'enabled','Enable Lockpicking guide and chest tracking'},{'record','Remember world chests I open'},{'circles','Show chest circles'},{'known','Include known footlocker spawn positions'},{'world','Show on world map'},{'minimap','Show on minimap'}})do
  local key,label=v[1],v[2];rows[#rows+1]=UI.CheckRow(canvas,Cfg,{label=label,default=true,get=function()return db[key]end,set=function(value)db[key]=value;L:UpdateMaps();HP.Refresh()end},width)
 end
 rows[#rows+1]=UI.DropdownRow(canvas,Cfg,{label='Training zone',items=function()
  local list={{value='auto',text='Automatic · current skill'}};local maps={}
  for _,band in ipairs(BANDS)do for _,map in ipairs(band.maps)do maps[map]=true end end
  local sorted={};for map in pairs(maps)do sorted[#sorted+1]=map end;table.sort(sorted)
  for _,map in ipairs(sorted)do local info=HP.Call(C_Map.GetMapInfo,map);list[#list+1]={value=map,text=info and info.name or tostring(map)}end;return list
 end,get=function()return db.zone end,set=function(value)db.zone=value;HP.manualWaypoint=nil;HP.Refresh()end},width)
 rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Open skill-based Lockpicking guide',button='Open guide',run=function()HP.db.professionGuide='Lockpicking';HP.ChooseGuideBook('professions')end},width)
 rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Save chest at my current position',desc='Manual approximate mark. Inventory/trade lockboxes are never recorded automatically.',button='Save',run=function()local saved=L:Record(0,HP.GatherPosition(),'Manually marked chest','Manually marked near here');L:UpdateMaps();HP.Refresh();D:Print(saved and 'Chest location saved (approximate).'or 'Chest not saved: enable recording on a Rogue and use a mapped zone.')end},width)
 rows[#rows+1]=UI.InfoRow(canvas,'Gold: known spawn. Green: opened/marked by you. Red: above your current skill. Positions are possible spawns, never live chest detection. Live object requirements take priority over guide estimates.',width)
 return rows
end
local build=Cfg.TABS[Cfg.TAB.professions].build
Cfg.TABS[Cfg.TAB.professions].build=function(canvas,width)
 local rows=build(canvas,width);rows[#rows+1]=UI.PageRow(canvas,Cfg,{label='Lockpicking · skill routes & chest circles',open=function()Cfg:OpenPage(page)end},width);return rows
end
D:On('PLAYER_LOGIN',function()L:DB()end)
local events=CreateFrame('Frame');L.events=events
for _,event in ipairs({'UNIT_SPELLCAST_SENT','UNIT_SPELLCAST_SUCCEEDED','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_INTERRUPTED','LOOT_OPENED','LOOT_READY','SKILL_LINES_CHANGED','CHAT_MSG_SKILL','PLAYER_LEVEL_UP','PLAYER_ENTERING_WORLD','ZONE_CHANGED_NEW_AREA'})do pcall(events.RegisterEvent,events,event)end
events:SetScript('OnEvent',function(_,event,...)D:Safe(L.OnEvent,L,event,...)end)
local driver=CreateFrame('Frame');L.driver=driver;local elapsed,miniElapsed=0,0
 driver:SetScript('OnUpdate',function(_,dt)
 if not HP.db or not D.db then return end
 elapsed=elapsed+dt
 if elapsed>=.5 then elapsed=elapsed%.5;miniElapsed=0;L:UpdateMaps()
 else miniElapsed=miniElapsed+dt;if miniElapsed>=.1 then miniElapsed=miniElapsed%.1;L:UpdateMaps(true)end end
end)
local update=D.Panel.Update
function D.Panel:Update(...)
 local result=update(self,...)
 if HP.db and HP.db.guideBook=='professions'and HP.db.professionGuide=='Lockpicking'and self.frame then
  local task=HP.auxTask;self.frame.next:SetEnabled(task and task.lockNode~=nil)
  self.frame.prev:SetEnabled(L.lastSkipped~=nil)
 end
 return result
end

end)
