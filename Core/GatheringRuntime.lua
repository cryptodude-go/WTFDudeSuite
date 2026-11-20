-- Historical gathering circles/circuits only. Live minimap probing and sounds are retired.
local _,HP=...
HP.liveGathering={nodes={},alerts={},ignored={},status='Known spawn circles and saved gathering history'}
function HP.GetLiveGatherPoint()end
function HP.LiveGatherTick()end
function HP.SkipLiveGatherNode()end
function HP.LiveGatherStatus()return HP.liveGathering.status end
function HP.LiveGatheringAvailable()return false end
local D=HP.Native;local C,UI=D.Config,D.UI
C.TABS[#C.TABS+1]={key='gathering',label='Gathering',pad=UI.SIZE.pad,gap=UI.SIZE.gap,build=function(canvas,width)
 local rows={}
 for _,kind in ipairs({'Herbalism','Mining'})do
  local name=kind
  rows[#rows+1]=UI.ButtonRow(canvas,C,{label=name..' 1–300',desc='Known node circles, gathering history and skill-based routes.',button='Open guide',run=function()HP.db.professionGuide=name;HP.ChooseGuideBook('professions')end},width)
 end
 rows[#rows+1]=UI.InfoRow(canvas,'Colored circles are known possible spawns; green circles are places you gathered. Circles do not confirm a resource is currently present. Live node detection, node sounds and automatic live-node detours have been removed.',width)
 return rows
end};C.TAB.gathering=#C.TABS
D:On('PLAYER_LOGIN',function()
 if not HP.db then return end
 for _,key in ipairs({'liveGatherEnabled','liveGatherSoundEnabled','liveGatherSound','liveGatherDetour','liveGatherHerbs','liveGatherMining'})do HP.db[key]=nil end
 HP.liveGathering.target=nil;HP.liveGathering.scan=nil
end)
