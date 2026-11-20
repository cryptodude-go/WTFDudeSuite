local addon,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
function HP.GetDingVersion()
 return HP.Call(C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata,addon,'Version') or '0.19.2'
end
local function label(parent,text,x,y,width)
 local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',12);t:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y);t:SetWidth(width or 450);t:SetJustifyH('LEFT');t:SetTextColor(1,.86,.55);t:SetText(text);return t
end
local function basic(parent,title,click)
 local b=CreateFrame('Button',nil,parent,'BackdropTemplate');b:SetSize(510,30);b:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});b:SetBackdropColor(.13,.08,.035,1);b:SetBackdropBorderColor(.65,.47,.23,1);b.bg=b:CreateTexture(nil,'BACKGROUND');b.bg:SetAllPoints();b.bg:SetTexture(WHITE);b.bg:SetVertexColor(.13,.08,.035,1);b.label=label(b,title,10,-8);b:SetScript('OnClick',click);return b
end
local function toggle(parent,title,key,default)
 local b=basic(parent,title,function() end)
 b.track=CreateFrame('Frame',nil,b,'BackdropTemplate');b.track:SetSize(64,20);b.track:SetPoint('RIGHT',b,'RIGHT',-8,0);b.track:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1})
 b.state=b.track:CreateFontString(nil,'OVERLAY');b.state:SetFont('Fonts\\FRIZQT__.TTF',10);b.state:SetAllPoints();b.state:SetJustifyH('CENTER')
 function b:Refresh() local on=HP.db[key];if on==nil then on=default end;self.track:SetBackdropColor(on and .05 or .23,on and .55 or .1,on and .15 or .08,1);self.state:SetText(on and 'ON' or 'OFF') end
 b:SetScript('OnClick',function() local on=HP.db[key];if on==nil then on=default end;HP.db[key]=not on
  b:Refresh();HP.Refresh()
 end)
 b:Refresh();return b
end
local function selected()
 local name=HP.db.professionGuide
 if name~='Mining' and name~='Herbalism' then
  local skills=HP.ProfessionSkills();name=skills[186] and 'Mining' or 'Herbalism';HP.db.professionGuide=name
 end
 return name
end
local extra=HP.RenderExtraSettingsPage
function HP.RenderExtraSettingsPage(p,page,line,control,existing)
 if page~='Gathering' then return extra(p,page,line,control,existing) end
 if p.bookMenu then p.bookMenu:Hide() end;if p.professionMap then p.professionMap:Hide() end
 local name=selected();local task=HP.ProfessionTask(name);p.gatherRenderedRank=task.rank
 line(name..' '..task.rank..'/300 · current cap '..task.maximum,14,0,-42):SetHeight(32)
 local chooser
 chooser=control('Profession: '..name..'   v',-83,function()
  HP.ChooseBookOption(chooser,{{value='Mining',label='Mining'},{value='Herbalism',label='Herbalism'}},function(value) HP.db.professionGuide=value;HP.db.gatherResource=nil;HP.db.gatherZone='auto';HP.InvalidateGathering();HP.Refresh();p.ShowPage('Gathering') end)
 end)
 local resource=HP.gatherNodeInfo[HP.db.gatherResource]
 local res
 res=control('Resource: '..(resource and resource.name or 'Automatic / current skill band')..'   v',-123,function()
  local choices={{value=false,label='Automatic / current skill band'}};local list={}
  for id,info in pairs(HP.gatherNodeInfo) do if info.kind==name and info.min<=task.rank and task.rank<(info.gray or info.min+100) then list[#list+1]={value=id,label=info.name..' · skill '..info.min..'+',min=info.min} end end
  table.sort(list,function(a,b) if a.min==b.min then return a.value<b.value end;return a.min<b.min end);for _,r in ipairs(list) do choices[#choices+1]=r end
  HP.ChooseBookOption(res,choices,function(value) HP.db.gatherResource=value or nil;HP.InvalidateGathering();HP.Refresh();p.ShowPage('Gathering') end)
 end)
 local zone;local zoneInfo=type(HP.db.gatherZone)=='number' and HP.Call(C_Map and C_Map.GetMapInfo,HP.db.gatherZone)
 zone=control('Farm zone: '..(zoneInfo and zoneInfo.name or 'Automatic / use current suitable zone')..'   v',-163,function()
  local choices={{value='auto',label='Automatic / use current suitable zone'}};local maps={}
  for map in pairs(HP.gatherSeeds) do if HP.GatherRoute(task,map) then local info=HP.Call(C_Map and C_Map.GetMapInfo,map);maps[#maps+1]={value=map,label=info and info.name or tostring(map)} end end
  table.sort(maps,function(a,b) return a.label<b.label end);for _,r in ipairs(maps) do choices[#choices+1]=r end
  HP.ChooseBookOption(zone,choices,function(value) HP.db.gatherZone=value;HP.InvalidateGathering();HP.Refresh();p.ShowPage('Gathering') end)
 end)
 existing(p.gatherNodeToggle,-211);p.gatherNodeToggle:Refresh()
 existing(p.gatherRecordToggle,-250);p.gatherRecordToggle:Refresh()
 control('Start '..name..' guide',-298,function() HP.ChooseGuideBook('professions');HP.Refresh();p:Hide() end)
 control('Rebuild circuit from the nearest node',-338,function() HP.InvalidateGathering();HP.Refresh();p.ShowPage('Gathering') end)
 local route=task.gatherRoute;local map=HP.GatherCurrentMap();local nodes=HP.GatherMapNodes(map,task);local recorded=0;for _,n in ipairs(HP.db.gatherNodes and HP.db.gatherNodes[map] or {}) do if HP.gatherNodeInfo[n.id] and HP.gatherNodeInfo[n.id].kind==name then recorded=recorded+1 end end
 line(#nodes..' suitable known positions in this zone · '..recorded..' gathered by you.',12,0,-390):SetHeight(45)
 line('Gold: possible locations. Green: your gathered locations. Use Find Minerals / Find Herbs for live nodes. Follow the circuit; skill gains change the target band.',12,0,-441):SetHeight(65)
 if resource and resource.min>task.rank then line('Requires '..resource.min..' '..name..'. Select a lower resource or Automatic.',12,0,-516):SetHeight(55)
 elseif task.training then line(task.rows[1].text,12,0,-516):SetHeight(55)
 elseif route then local info=HP.Call(C_Map and C_Map.GetMapInfo,route.mapID);line('Current circuit: '..(info and info.name or 'zone')..' · '..#route.nodes..' stops · target '..math.min(task.step.to,task.maximum),12,0,-516):SetHeight(55) end
 p.content:SetHeight(610);return true
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local p=HP.settings
 local nav=basic(p,'Gathering',function() p.ShowPage('Gathering') end);nav:SetSize(184,29);nav:SetPoint('TOPLEFT',p,'TOPLEFT',14,-242);p.navigationButtons.Gathering=nav
 for _,row in ipairs({{'Reputation',276},{'Chapters',310},{'Guide Mode',344},{'Navigation',398},{'Map',432},{'Display',466},{'Options',500},{'Announcements',534}}) do local b=p.navigationButtons[row[1]];b:ClearAllPoints();b:SetPoint('TOPLEFT',p,'TOPLEFT',14,-row[2]) end
 if type(p.GetRegions)=='function' then for _,r in ipairs({p:GetRegions()}) do if HP.Call(r.GetText,r)=='SETTINGS' then r:ClearAllPoints();r:SetPoint('TOPLEFT',p,'TOPLEFT',18,-373) end end end
 p.gatherNodeToggle=toggle(p.content,'Show known and gathered node circles','gatherShowNodes',true)
 p.gatherRecordToggle=toggle(p.content,'Remember nodes gathered by this character','gatherRecord',true)
 for _,b in ipairs({p.gatherNodeToggle,p.gatherRecordToggle}) do p.controls[#p.controls+1]=b;b:Hide() end
 local slash=SlashCmdList.DUDEWHERESMYDING
 SlashCmdList.DUDEWHERESMYDING=function(input)
  if input=='gather' or input=='gathering' or input=='gather map' then p.ShowPage('Gathering');p:Show();return
 end
  return slash(input)
 end
end
