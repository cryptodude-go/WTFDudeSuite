local _,HP=...
local colors={observed={.25,1,.4},Fishing={.25,.75,1},Herbalism={.55,1,.25},Mining={1,.76,.15}}
local function line(f,index,a,b,w,h)
 f.lines=f.lines or {};local l=f.lines[index]
 if not l then l=HP.Call(f.CreateLine,f,nil,'OVERLAY');if l then f.lines[index]=l end end
 if l then l:SetThickness(2);l:SetColorTexture(.25,.95,.45,.95);l:SetStartPoint('TOPLEFT',f,'TOPLEFT',a.x*w,-a.y*h);l:SetEndPoint('TOPLEFT',f,'TOPLEFT',b.x*w,-b.y*h);l:Show() end
end
function HP.DrawGatherCircuit(f,route,w,h)
 for _,l in ipairs(f.lines or {}) do l:Hide() end
 if not route or HP.db.hideRouteLines then return end
 for i=2,#route.points do line(f,i-1,{x=route.points[i-1][1],y=route.points[i-1][2]},{x=route.points[i][1],y=route.points[i][2]},w,h) end
end
function HP.DrawGatherCircles(f,map,task,w,h,project)
 f.nodes=f.nodes or {}
 if HP.db.gatherShowNodes==false then for _,b in ipairs(f.nodes)do b:Hide()end;f.renderWidth=nil;return end
 local source=task.displayAll and HP.GatherDisplayNodes(map,task.allProfessions) or HP.GatherMapNodes(map,task)
 local key=task.book.name..':'..tostring(map)..':'..tostring(HP.gatherRevision or 0)
 if not project and f.nodeSource==source and f.nodeKey==key and f.renderWidth==w and f.renderHeight==h then return end
 for _,b in ipairs(f.nodes)do b:Hide()end
 f.renderWidth=not project and w or nil;f.renderHeight=not project and h or nil
 local nodes=f.nodeList
 if not nodes or f.nodeSource~=source or f.nodeKey~=key then
 nodes={};for _,p in ipairs(source) do nodes[#nodes+1]=p end
 for _,p in ipairs(not task.displayAll and HP.db.gatherNodes and HP.db.gatherNodes[map] or {}) do
  local info=HP.gatherNodeInfo[p.id]
  if info and info.kind==task.book.name then
   local seen=false;for _,n in ipairs(nodes) do if n.id==p.id and math.abs(n.x-p.x)+math.abs(n.y-p.y)<.008 then seen=true;break end end
   if not seen then nodes[#nodes+1]={mapID=map,x=p.x,y=p.y,id=p.id,observed=true,source='Gathered by you'} end
  end
 end
 table.sort(nodes,function(a,b) if a.observed~=b.observed then return a.observed==true end;if a.id~=b.id then return a.id<b.id end;if a.x~=b.x then return a.x<b.x end;return a.y<b.y end)
 f.nodeList=nodes;f.nodeSource=source;f.nodeKey=key
 end
 local count=0
 for _,p in ipairs(nodes) do
  local x,y
  if project then x,y=project(p) else x,y=p.x*w,-p.y*h end
  if x and y then count=count+1;if project and count>160 then break end
   local b=f.nodes[count]
   if not b then
    b=CreateFrame('Button',nil,f);f.nodes[count]=b;b:SetSize(13,13)
    b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetAllPoints();b.icon:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\PortraitRing')
    b:SetScript('OnEnter',function(self)
     local info=HP.gatherNodeInfo[self.node.id]
     if not GameTooltip then return end
     GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(info and info.name or 'Gathering node')
     GameTooltip:AddLine((self.node.observed and 'Gathered by you' or self.node.source)..' · possible location',.8,.9,.7,true)
     if info and info.kind=='Fishing' then
      GameTooltip:AddLine('Fishing pool · cast from a reachable shoreline.',1,.85,.4,true)
     else
      GameTooltip:AddLine('Requires '..self.profession..' '..(info and info.min or '?'),1,.85,.4)
     end
     GameTooltip:AddLine('Click to navigate here. Respawn is not guaranteed.',.8,.8,.8,true);GameTooltip:Show()
    end)
    b:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    b:SetScript('OnClick',function(self)
     if HP.nativeStarted then
      local p=self.node;SlashCmdList.DWMGDING(('way %d %.4f %.4f %s'):format(p.mapID,p.x*100,p.y*100,(HP.gatherNodeInfo[p.id] or {}).name or 'Gathering node'))
     else HP.manualWaypoint={mapID=self.node.mapID,x=self.node.x,y=self.node.y};HP.Refresh() end
    end)
   end
   b.node=p;b.profession=(HP.gatherNodeInfo[p.id] or {}).kind or task.book.name;b:ClearAllPoints();b:SetPoint('CENTER',f,'TOPLEFT',x,y);local color=colors[p.observed and 'observed' or b.profession] or colors.Mining
   b.icon:SetVertexColor(color[1],color[2],color[3],1);b:Show()
  end
 end
end
local function context(world)
 if not HP.db or HP.Suite and not HP.Suite:On('gathering') or HP.db.gatherShowNodes==false then return end
 local all=world and HP.db.gatherWorldAllProfessions~=false
 if HP.HasGatherDisplay and not HP.HasGatherDisplay(all)then return end
 return {book={name='All'},displayAll=true,allProfessions=all}
end
local build=HP.BuildGatherMap
function HP.BuildGatherMap(p,map,x,y,task)
 build(p,map,x,y,task)
 if task and (task.book.name=='Mining' or task.book.name=='Herbalism') then
  local f=p.professionMap;HP.DrawGatherCircles(f,map,task,340,220)
  f.caption:SetText((HP.Call(C_Map and C_Map.GetMapInfo,map) or {}).name or 'Gathering circuit')
 end
end
local minimap=HP.DrawGatherMinimap
function HP.DrawGatherMinimap()
 minimap()
 if HP.gatherNodeMini then for _,b in ipairs(HP.gatherNodeMini.nodes or {}) do b:Hide() end;HP.gatherNodeMini:Hide() end
 if HP.Suite and not HP.Suite:On('gathering') then return end
 local t=context()
 if not t or HP.db.gatherMinimapNodes==false or not Minimap or not Minimap:IsShown() then return end
 local f=HP.gatherNodeMini
 if not f then f=CreateFrame('Frame',nil,Minimap);HP.gatherNodeMini=f;f:SetAllPoints(Minimap);f:SetFrameLevel(Minimap:GetFrameLevel()+21);f:EnableMouse(false) end
 f:Show();local radius=HP.GatherMinimapRadius()
 local w,h=Minimap:GetWidth(),Minimap:GetHeight();local angle=HP.Call(GetCVar,'rotateMinimap')=='1' and (HP.Call(GetPlayerFacing) or 0) or 0
 local vector=HP.GatherMinimapVector()
 HP.DrawGatherCircles(f,HP.GatherCurrentMap(),t,w,h,function(p)
  local dx,dy=vector(p);if not dx then return end
  local x=(dx*math.cos(angle)+dy*math.sin(angle))/radius*w/2;local y=(dy*math.cos(angle)-dx*math.sin(angle))/radius*h/2
  if x*x+y*y<=math.max(0,math.min(w,h)*.47-7)^2 then return w/2+x,-h/2+y end
 end)
end
local worlds={}
function HP.UpdateGatherWorldNodes()
 for _,f in pairs(worlds) do f:Hide() end
 local t=context(true)
 local canvas=WorldMapFrame and HP.MapCanvas(WorldMapFrame)
 if not t or not canvas or not WorldMapFrame:IsShown() or HP.db.gatherShowNodes==false or HP.db.gatherWorldNodes==false then return end
 local map=HP.Call(WorldMapFrame.GetMapID,WorldMapFrame);if not map then return end
 local f=worlds[canvas];if not f then f=CreateFrame('Frame',nil,canvas);worlds[canvas]=f;f:SetAllPoints(canvas);f:SetFrameLevel(canvas:GetFrameLevel()+22);f:EnableMouse(false) end
 HP.gatherWorldNodesFrame=f;f:Show();HP.DrawGatherCircles(f,map,t,canvas:GetWidth(),canvas:GetHeight())
end
local create=HP.CreateUI
function HP.CreateUI()
 create()
 -- The separate gathering map and all of its saved appearance settings are retired.
 HP.db.gatherOverlayEnabled=nil;HP.db.gatherOverlayPinned=nil;HP.db.gatherOverlayPosition=nil;HP.db.gatherOpacity=nil
 local ticker=CreateFrame('Frame',nil,UIParent);HP.gatherTicker=ticker;local elapsed,miniElapsed=0,0
 ticker:SetScript('OnUpdate',function(_,dt)
  if not HP.db then return end
  -- Match the native minimap's 10 Hz placement rate instead of redrawing every frame.
  miniElapsed=miniElapsed+dt
  if miniElapsed>=.1 then miniElapsed=miniElapsed%.1;HP.DrawGatherMinimap()end
  elapsed=elapsed+dt;if elapsed<.5 then return end;elapsed=0
  local name=HP.db.professionGuide;local gathering=name=='Mining' or name=='Herbalism'
  local p=HP.settings;local page=p and p:IsShown() and p.page=='Gathering'
  if gathering and (HP.auxiliaryActive or page) then HP.TickGatherRoute() end
  HP.UpdateGatherWorldNodes()
  if gathering and page and not (p.bookMenu and p.bookMenu:IsShown()) then local task=HP.ProfessionTask(name);if task and p.gatherRenderedRank~=task.rank then p.ShowPage('Gathering') end end
 end)
end
local refresh=HP.Refresh
function HP.Refresh(...)
 local result=refresh(...);HP.UpdateGatherWorldNodes();HP.DrawGatherMinimap();return result
end
