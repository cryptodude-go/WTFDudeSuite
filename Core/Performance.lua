local _,_WTF=...
_WTF.Defer(40,'Core/Performance.lua',function(...)
-- Suspend optional background drivers and keep diagnostics demand-driven.
local _,HP=...
local D=HP.Native;local P={};HP.Performance=P
local function enabled(key)return HP.Suite:On(key)end
function P:Driver(frame,on,cleanup)
 if not frame then return end
 on=on==true
 if frame.dudePerformanceAwake==on then return end
 frame.dudePerformanceAwake=on
 if not on and cleanup then cleanup()end
 frame:SetShown(on)
end
function P:Reconcile()
 if not HP.db or not D.db then return end
 local route=HP.auxiliaryActive and not HP.db.hidden and not HP.db.paused and (HP.db.professionGuide=='Mining'or HP.db.professionGuide=='Herbalism')
 local display=HP.HasGatherDisplay and HP.HasGatherDisplay()
 local maps=enabled('gathering')and (route or display and (HP.db.gatherMinimapNodes~=false or HP.db.gatherWorldNodes~=false and WorldMapFrame and WorldMapFrame:IsShown()))
 self:Driver(HP.gatherTicker,maps,function()HP.UpdateGatherWorldNodes();HP.DrawGatherMinimap()end)
 self:Driver(HP.liveGatherDriver,enabled('gathering')and HP.db.liveGatherEnabled==true,function()
  if HP.liveGathering.target or HP.liveGathering.scan then HP.LiveGatherTick()end
 end)
 self:Driver(HP.Lockpicking.driver,HP.Lockpicking:Enabled()and not HP.db.hidden and not HP.db.paused,function()HP.Lockpicking:UpdateMaps()end)
 self:Driver(HP.Rares.driver,enabled('rares'))
 self:Driver(HP.GroupMarks.ticker,enabled('marking'))
 local spam=HP.SpamFilter
 self:Driver(spam.ticker,enabled('spam')and (#spam.queue>0 or next(spam.pending)~=nil))
 self:Driver(HP.GearScore.driver,HP.GearScore:Enabled(),function()HP.GearScore:RefreshOverlays()end)
end
-- Only stable pages are reusable. Dynamic lists/gear profiles retain their rebuild path.
for _,page in ipairs({HP.nativeSparklesPage,HP.GatheringSkills.page,HP.Lockpicking.page})do if page then page.cache=true end end
local refresh=HP.Suite.Refresh
function HP.Suite:Refresh(...)
 local result=refresh(self,...);P:Reconcile();return result
end
D:On('PLAYER_LOGIN',function()P:Reconcile()end)
for _,event in ipairs({'SKILL_LINES_CHANGED','PLAYER_ENTERING_WORLD'})do D:On(event,function()P:Reconcile()end)end
local driver=CreateFrame('Frame');P.driver=driver;local elapsed=0
driver:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<1 then return end;elapsed=elapsed%1
 P:Reconcile()
end)
-- Explicit snapshots only: no per-frame memory sweeps or forced garbage collection.
function P:Snapshot()
 local stats=C_AddOns
 local update=stats and stats.UpdateAddOnMemoryUsage or UpdateAddOnMemoryUsage
 HP.Call(update)
 local kb,cpu;local entries={}
 local function add(name)
  local mem=HP.Call(stats and stats.GetAddOnMemoryUsage or GetAddOnMemoryUsage,name)
  local used=HP.Call(GetCVar,'scriptProfile')=='1'and HP.Call(GetAddOnCPUUsage,name)
  if HP.Public(mem)and type(mem)=='number'then kb=(kb or 0)+mem end
  if HP.Public(used)and type(used)=='number'then cpu=(cpu or 0)+used end
  entries[#entries+1]={addon=name,memoryKB=mem,cpuMS=used}
 end
 add(HP.addonName)
 return {memoryKB=kb,cpuMS=cpu,modules=entries}
end
function P:Report()
  local result=self:Snapshot()
  D:Print('Performance snapshot · RAM: '..(result.memoryKB and string.format('%.1f MB',result.memoryKB/1024)or 'unavailable')..' · cumulative CPU: '..(result.cpuMS and string.format('%.1f ms',result.cpuMS)or 'unavailable')..'. CPU measurement needs client profiling; this is not CPU percent.')
end
local C,UI=D.Config,D.UI
local build=C.TABS[C.TAB.appearance].build
C.TABS[C.TAB.appearance].build=function(canvas,width)
 local rows=build(canvas,width)
 rows[#rows+1]=UI.ButtonRow(canvas,C,{label='Performance snapshot',desc='Print RAM and available cumulative CPU usage. Measured only when requested.',button='Check',run=function()P:Report()end},width)
 return rows
end
local command=SlashCmdList.WTFDUDESUITE
SlashCmdList.WTFDUDESUITE=function(input)
 if (input or ''):lower():match('^%s*performance%s*$')then P:Report();return end
 return command(input)
end

end)
