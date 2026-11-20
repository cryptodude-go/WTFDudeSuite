local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(10,'sparkles',function(...)
-- Quest-loot highlight controller and native options for the integrated sparkle runtime.
-- The approaching-node runtime is adapted from Ashtar Senior's GPL-3.0-or-later work.
local _,HP=...
local S=HP.Sparkles
local D=HP.Native
local wanted={outlineModeShowLootEffectWhenDisabled='1',graphicsOutlineMode='0',OutlineEngineMode='0',raidGraphicsOutlineMode='0',RAIDOutlineEngineMode='0'}
local disabled={outlineModeShowLootEffectWhenDisabled='0',graphicsOutlineMode='2',OutlineEngineMode='2',raidGraphicsOutlineMode='2',RAIDOutlineEngineMode='2'}
local watched={graphicsquality=true,raidgraphicsquality=true}
for key in pairs(wanted)do watched[key:lower()]=true end
local applying,pending,due=false,nil,nil
local function get(key)return HP.Call(C_CVar and C_CVar.GetCVar or GetCVar,key)end
local function set(key,value)
 if get(key)~=nil and get(key)~=value then HP.Call(C_CVar and C_CVar.SetCVar or SetCVar,key,value)end
end
local function apply(on)
 if HP.Suite and not HP.Suite:On('sparkles') then on=false end
 if not S.db then return end
 if HP.Call(InCombatLockdown) then pending=on;return end
 applying=true
 for key,value in pairs(on and wanted or disabled)do set(key,value)end
 applying=false;pending=nil
 if on then S.sparklesShown=true end
end
function S.ApplySuite() if S.db then apply(S.db.enabled);S.RefreshSoftTarget() end end
function S.SetQuestEnabled(on)
 S.db.enabled=on;due=nil;apply(on)
end
local timer=CreateFrame('Frame');S.timer=timer
function S.Init()
 if S.db then return end
 HP.db.sparkles=HP.db.sparkles or {};S.db=HP.db.sparkles
 -- This release fulfills the requested 'everything on' setup once per
 -- character. Subsequent checkbox edits are retained across logins/reloads.
 if not S.db.allCategories0192 then
  for _,key in ipairs({'enabled','sparkleOre','sparkleHerbs','sparkleQuest','sparkleCorpseLoot'})do S.db[key]=true end
  S.db.allCategories0192=true
 end
 if S.db.enabled==nil then S.db.enabled=true end
 S.InitSoftTarget(S.db)
 if S.db.enabled then apply(true);due=(HP.Call(GetTime) or 0)+5 end
end
D:On('PLAYER_LOGIN',function()S.Init()end)
local events=CreateFrame('Frame');S.events=events
for _,event in ipairs({'CVAR_UPDATE','PLAYER_REGEN_ENABLED','PLAYER_ENTERING_WORLD','VARIABLES_LOADED'})do pcall(events.RegisterEvent,events,event)end
events:SetScript('OnEvent',function(_,event,key)
 if not S.db then return end
 if event=='PLAYER_REGEN_ENABLED' then
  if pending~=nil then apply(pending) end
 elseif event=='PLAYER_ENTERING_WORLD' or event=='VARIABLES_LOADED' then
  if S.db.enabled then due=(HP.Call(GetTime) or 0)+1 end
 elseif not applying and type(key)=='string' and watched[key:lower()] and S.db.enabled then
  due=(HP.Call(GetTime) or 0)+1
 end
end)
timer:SetScript('OnUpdate',function()
 if due and (HP.Call(GetTime) or 0)>=due then due=nil;if S.db and S.db.enabled then apply(true);S.RefreshSoftTarget()end end
end)
local C,UI=D.Config,D.UI
local page={key='dude-sparkles',title='Loot and gathering sparkles'}
function page.build(canvas,width)
 local rows={UI.HeaderRow(canvas,'World highlights',width)}
 local function check(label,key,desc,default,quest)
  rows[#rows+1]=UI.CheckRow(canvas,C,{label=label,desc=desc,default=default,
   get=function()local db=S.db or HP.db.sparkles or {};if db[key]==nil then return default end;return db[key]==true end,
   set=function(value)S.Init();if quest then S.SetQuestEnabled(value)else S.db[key]=value;S.RefreshSoftTarget()end end},width)
 end
 check('Show quest item sparkles','enabled','Keeps quest loot sparkling after graphics preset changes.',true,true)
 rows[#rows+1]=UI.HeaderRow(canvas,'Sparkles while approaching',width)
 check('Ore veins','sparkleOre','Glints and an interaction icon on the nearest mining node.',true)
 check('Herbs','sparkleHerbs','Glints and an interaction icon on the nearest herb.',true)
 check('Quest objects','sparkleQuest','Extra nearby highlights for unfinished quest objects.',true)
 check('Corpses with loot','sparkleCorpseLoot','Highlights a nearby corpse that still has loot for you.',true)
 rows[#rows+1]=UI.InfoRow(canvas,'Nearby glints use the game’s soft interaction target (about 15 yards). Dim means far away; gray means unavailable. Combat can delay changes. Turning quest item sparkles off requires a full game restart.',width)
 return rows
end
HP.nativeSparklesPage=page
local build=C.TABS[C.TAB.appearance or 6].build
C.TABS[C.TAB.appearance or 6].build=function(canvas,width)
 local rows=build(canvas,width)
 if HP.Suite then return rows end
 table.insert(rows,1,UI.PageRow(canvas,C,{label='Loot and gathering sparkles',desc='Choose quest items, ore, herbs, quest objects and corpses.',open=function()C:OpenPage(page)end},width))
 return rows
end

end)
