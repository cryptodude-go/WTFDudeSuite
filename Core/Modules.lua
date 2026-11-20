-- Shared runtime services; bundled modules register before PLAYER_LOGIN.
local addonName,HP=...
HP.addonName=addonName
_G.WTFDudeSuiteRuntime=HP
HP.moduleFolders={["leveling"]="Modules/Leveling",["professions"]="Modules/Professions",["reputation"]="Modules/Reputation",["gathering"]="Modules/Gathering",["navigation"]="Modules/Navigation",["automation"]="Modules/AutoQuests",["sparkles"]="Modules/Sparkles",["marking"]="Modules/GroupMarks",["spam"]="Modules/Ignore",["rares"]="Modules/RareScanner",["travel"]="Modules/Travel",["community"]="Modules/Community"}
HP.loadedModules={};HP.moduleInitializers={}
function HP.Defer(priority,key,fn)
 HP.moduleInitializers[#HP.moduleInitializers+1]={priority=priority,key=key,fn=fn,order=#HP.moduleInitializers+1}
end
function HP.ModuleAvailable(key)
 if key=='suite'then return true end
 if key=='gear'then key='automation'end
 return HP.loadedModules[key]==true
end
function HP.InitializeModules()
 if HP.modulesInitialized then return end
 table.sort(HP.moduleInitializers,function(a,b)if a.priority==b.priority then return a.order<b.order end;return a.priority<b.priority end)
 for _,entry in ipairs(HP.moduleInitializers)do entry.fn('WTFDudeSuite',HP)end
 HP.modulesInitialized=true;HP.moduleInitializers={}
 if HP.pendingNativeMigration then HP.pendingNativeMigration=nil;HP.MigrateNativeBridge('ADDON_LOADED','WTFDudeSuite')end
end
local noop=function()end
local function empty()return {}end
local disabled={enabled=false}
local function service(methods)
 local t={DB=function()return disabled end,Enabled=function()return false end,Apply=noop,Update=noop,Tick=noop}
 for _,k in ipairs(methods or {})do t[k]=noop end;return t
end
HP.GroupMarks=service({'Scan','Paint'})
HP.SpamFilter=service({'Changed'});HP.SpamFilter.queue={};HP.SpamFilter.pending={}
HP.Rares=service({'NavigationPoint','Scan','Remove'});HP.Rares.records={}
function HP.Rares:ID(guid)
 if not HP.Public(guid)or type(guid)~='string'then return end
 local kind,id=guid:match('^([^-]+)%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)%-')
 if kind=='Creature'or kind=='Vehicle'or kind=='GameObject'then return tonumber(id),kind end
end
HP.TravelClock=service();HP.TravelDisplay=service();HP.GearScore=service({'RefreshOverlays'})
HP.Lockpicking=service({'UpdateMaps'});HP.GatheringSkills=service()
HP.Sparkles={ApplySuite=noop}
for _,name in ipairs({'nativeGroupMarksPage','nativeTravelPage','nativeSparklesPage'})do HP[name]={build=empty}end
HP.Lockpicking.page={build=empty};HP.GatheringSkills.page={build=empty}
HP.Announce=noop
HP.Suite={On=function(_,key)return HP.ModuleAvailable(key)end}
-- The first-created login frame initializes all module wrappers before the core login handlers.
local login=CreateFrame('Frame');HP.moduleLoginFrame=login;login:RegisterEvent('PLAYER_LOGIN')
login:SetScript('OnEvent',function()HP.InitializeModules()end)
