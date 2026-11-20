local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(30,'gathering',function(...)
-- Gathering requirements, integrated with Suite settings and existing localized node data.
local _,HP=...
local D=HP.Native;local UI,Cfg=D.UI,D.Config
local G={};HP.GatheringSkills=G
local ids={Herbalism=182,Mining=186,Skinning=393}
local colors={red={1,.15,.15},orange={1,.5,.25},yellow={1,1,0},green={.25,.75,.25},gray={.5,.5,.5}}
local function readable(v)return HP.Public(v)end
local function text(v)return readable(v)and type(v)=='string'end
local function number(v)return readable(v)and type(v)=='number'and v==v and v>=0 and v<100000 end
local function clean(v)
 if not text(v)then return end
 return (v:gsub('|T.-|t',''):gsub('|A.-|a',''):gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):gsub('^%s+',''):gsub('%s+$',''):gsub('%s*%(%d+%)$',''))
end
function G:DB()
 if not HP.db then return end
 HP.db.gatheringSkills=HP.db.gatheringSkills or {};local db=HP.db.gatheringSkills
 for _,k in ipairs({'enabled','Herbalism','Mining','Skinning'})do if db[k]==nil then db[k]=true end end
 return db
end
function G:Enabled(kind)
 local db=self:DB();return db and db.enabled and HP.Suite:On('gathering')and(not kind or db[kind])
end
function G:Difficulty(rank,need)
 if not number(rank)or rank<need then return 'red' end
 local diff=rank-need
 if diff<25 then return 'orange'elseif diff<50 then return 'yellow'elseif diff<100 then return 'green'else return 'gray'end
end
function G:SkinRequirement(level)
 if not number(level)or level<1 then return end
 if level<=10 then return 1 elseif level<=20 then return (level-10)*10 else return level*5 end
end
function G:Line(kind,need)
 if not self:Enabled(kind)or not number(need)then return end
 local entry=HP.ProfessionSkills()[ids[kind]];local rank=entry and entry.rank
 local color=colors[self:Difficulty(rank,need)]
 local line=number(rank)and string.format('%s: requires %d · your skill %d',kind,need,rank)or string.format('%s: requires %d · profession not learned',kind,need)
 return line,color
end
function G:Names()
 if self.names then return self.names end
 local names={}
 local function put(name,fact)name=clean(name);if name and name~=''then names[name]=fact end end
 for id,info in pairs(HP.gatherNodeInfo or {})do
  local fact={kind=info.kind,need=info.min};put(info.name,fact);put(D.Data:ObjectName(id),fact)
 end
 for name,id in pairs(HP.gatherAliasNames or {})do local info=HP.gatherNodeInfo[id];if info then put(name,{kind=info.kind,need=info.min})end end
 for id,canonical in pairs(HP.gatherNodeAliases or {})do local info=HP.gatherNodeInfo[canonical];if info then put(D.Data:ObjectName(id),{kind=info.kind,need=info.min})end end
 -- Classic quest-only mineral objects are not part of the ore route database.
 for name,need in pairs({['Incendicite Mineral Vein']=65,['Lesser Bloodstone Deposit']=75,['Indurium Mineral Vein']=150,['Hakkari Thorium Vein']=275})do
  if not names[name]then put(name,{kind='Mining',need=need})end
 end
 names.Wintersbite=names.Wintersbite or {kind='Herbalism',need=195}
 self.names=names;return names
end
function G:Lines(tooltip,data)
 local lines={};local name=HP.Call(tooltip.GetName,tooltip);local count=HP.Call(tooltip.NumLines,tooltip)
 if text(name)and number(count)then
  for i=1,math.min(count,100)do local region=_G[name..'TextLeft'..i];local value=region and HP.Call(region.GetText,region);if text(value)then lines[#lines+1]=value end end
 end
 if readable(data)and type(data)=='table'and readable(data.lines)and type(data.lines)=='table'then
  for _,line in ipairs(data.lines)do if readable(line)and type(line)=='table'and text(line.leftText)then lines[#lines+1]=line.leftText end end
 end
 return lines
end
function G:Apply(tooltip,mode,data)
 if self.busy or not tooltip or not self:Enabled()then return end
 local lines=self:Lines(tooltip,data);local requests={};local seen={}
 if mode=='unit'then
  local _,unit=HP.Call(tooltip.GetUnit,tooltip)
  if not text(unit)then return end
  local dead=HP.Call(UnitIsDead,unit);if not readable(dead)or not dead then return end
  local skinnable=false
  for _,line in ipairs(lines)do if clean(line)==UNIT_SKINNABLE_LEATHER then skinnable=true end end
  if not skinnable then return end
  local need=self:SkinRequirement(HP.Call(UnitLevel,unit));if need then requests[1]={kind='Skinning',need=need}end
 else
  local names=self:Names()
  for _,line in ipairs(lines)do
   local plain=clean(line)
   if plain then for part in plain:gsub('|n','\n'):gmatch('[^\n]+')do
    local label=clean(part);local fact=names[label]
    if fact and not seen[label]then seen[label]=true;requests[#requests+1]={kind=fact.kind,need=fact.need,label=label}end
   end end
  end
 end
 local have={};for _,line in ipairs(lines)do have[clean(line)]=true end
 self.busy=true;local added=false
 local ok,err=pcall(function()
  for _,request in ipairs(requests)do
   local line,color=self:Line(request.kind,request.need)
   if line then
    if #requests>1 then line=request.label..' · '..line end
    if not have[line]then tooltip:AddLine(line,color[1],color[2],color[3]);have[line]=true;added=true end
   end
  end
  if added then tooltip:Show()end
 end)
 self.busy=false;if not ok then self.lastError=err end
end
function G:Install()
 if self.installed or not GameTooltip then return end;self.installed=true
 local types=Enum and Enum.TooltipDataType;local processor=TooltipDataProcessor
 local function hook(kind,mode)
  if not(kind and processor and processor.AddTooltipPostCall)then return false end
  return pcall(processor.AddTooltipPostCall,kind,function(tooltip,data)D:Safe(G.Apply,G,tooltip,mode,data)end)
 end
 local object=hook(types and types.Object,'object');local unit=hook(types and types.Unit,'unit');local mini=hook(types and types.MinimapMouseover,'object')
 if not unit then pcall(GameTooltip.HookScript,GameTooltip,'OnTooltipSetUnit',function(t)D:Safe(G.Apply,G,t,'unit')end)end
 if not object then pcall(GameTooltip.HookScript,GameTooltip,'OnShow',function(t)
  local _,link=HP.Call(t.GetItem,t);local _,token=HP.Call(t.GetUnit,t)
  if not text(link)and not text(token)then D:Safe(G.Apply,G,t,'object')end
 end)end
 if not mini and hooksecurefunc then pcall(hooksecurefunc,GameTooltip,'SetText',function(t)
  if Minimap and HP.Call(t.GetOwner,t)==Minimap then D:Safe(G.Apply,G,t,'object')end
 end)end
end
local page={key='suite-gathering-skills',title='Gathering · skill requirements'};G.page=page
page.build=function(canvas,width)
 local rows={};local db=G:DB()
 for _,option in ipairs({{'enabled','Enable gathering skill tooltips'},{'Herbalism','Herbs · required skill and difficulty'},{'Mining','Mining · required skill and difficulty'},{'Skinning','Skinning · required skill on skinnable corpses'}})do
  local key,label=option[1],option[2]
  rows[#rows+1]=UI.CheckRow(canvas,Cfg,{label=label,default=true,get=function()return db[key]end,set=function(v)db[key]=v;GameTooltip:Hide()end},width)
 end
 rows[#rows+1]=UI.InfoRow(canvas,'Hover a world node or minimap dot to compare its required skill with yours. Red: unavailable. Orange / yellow / green / gray: estimated skill-up difficulty. Server-specific requirements may differ. Skinning needs a dead, skinnable corpse. Client-protected names cannot be read.',width)
 return rows
end
local build=Cfg.TABS[Cfg.TAB.gathering].build
Cfg.TABS[Cfg.TAB.gathering].build=function(canvas,width)
 local rows=build(canvas,width)
 table.insert(rows,2,UI.PageRow(canvas,Cfg,{label='Herbs, Mining & Skinning · skill tooltips',desc='Required skill, your skill and difficulty colors.',open=function()Cfg:OpenPage(page)end},width))
 return rows
end
D:On('PLAYER_LOGIN',function()G:DB();G:Install()end)
local events=CreateFrame('Frame');events:RegisterEvent('SKILL_LINES_CHANGED');events:RegisterEvent('CHAT_MSG_SKILL')
events:SetScript('OnEvent',function()HP.profSkillCache=nil end)

end)
