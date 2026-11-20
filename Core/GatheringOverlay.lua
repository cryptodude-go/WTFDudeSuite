local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local function routePoints(map,task)
 task=task or HP.auxTask;local points=task and task.gatherRoute and task.gatherRoute.mapID==map and task.gatherRoute.points or HP.gatherLoops[map]
 local list={};local route=task and task.gatherRoute
 if route and not route.suggested then
  local player=HP.GatherPosition(map);if player then list[#list+1]=player end
  for i=HP.gatherPoint or 1,#route.nodes do local p=route.nodes[i];if not HP.GatherVisitExpiry(p,task.book.name) then list[#list+1]={mapID=map,x=p.x,y=p.y} end end
 else for _,p in ipairs(points or {}) do list[#list+1]={mapID=map,x=p[1],y=p[2]} end end
 return list
end
local points=HP.TrailPoints
function HP.TrailPoints()
 if HP.auxiliaryActive then
  local task=HP.auxTask
  if not task or task.training then return {} end
  if not HP.manualWaypoint and HP.db.guideBook=='professions' and task.step and task.step.gather and not task.fishing then return routePoints(task.step.mapID) end
  local route,state=HP.route,HP.state;HP.route=nil;HP.state=nil;local result=points();HP.route,HP.state=route,state;return result
 end
 return points()
end

local function line(frame,index,x1,y1,x2,y2,width)
 frame.routeLines=frame.routeLines or {};local l=frame.routeLines[index]
 if not l then
  l=HP.Call(frame.CreateLine,frame,nil,'OVERLAY');if l then frame.routeLines[index]=l end
 end
 if l then l:SetThickness(width or 2);l:SetColorTexture(.3,.95,.5,.85);l:SetStartPoint('TOPLEFT',frame,'TOPLEFT',x1,-y1);l:SetEndPoint('TOPLEFT',frame,'TOPLEFT',x2,-y2);l:Show() end
end
function HP.BuildGatherMap(p,map,x,y,task)
 local f=p.professionMap
 if not f then
  f=CreateFrame('Frame',nil,p.content,'BackdropTemplate');p.professionMap=f;f:SetSize(340,220);f:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});f:SetBackdropColor(.025,.04,.025,1);f:SetBackdropBorderColor(.5,.6,.4,1);f.tiles={}
  f.caption=f:CreateFontString(nil,'OVERLAY');f.caption:SetFont('Fonts\\FRIZQT__.TTF',10);f.caption:SetPoint('BOTTOMLEFT',f,'TOPLEFT',0,4);f.player=f:CreateTexture(nil,'OVERLAY');f.player:SetTexture(WHITE);f.player:SetVertexColor(1,1,.8,1);f.player:SetSize(5,5)
 end
 f:ClearAllPoints();f:SetPoint('TOPLEFT',p.content,'TOPLEFT',x,y);f:Show();f.mapID=map
 for _,t in ipairs(f.tiles) do t:Hide() end;for _,l in ipairs(f.routeLines or {}) do l:Hide() end
 local layers=HP.Call(C_Map and C_Map.GetMapArtLayers,map);local layer=type(layers)=='table' and layers[1];local textures=HP.Call(C_Map and C_Map.GetMapArtLayerTextures,map,1)
 if layer and type(textures)=='table' then
  local lw,lh=layer.layerWidth or 1002,layer.layerHeight or 668;local tw,th=layer.tileWidth or 256,layer.tileHeight or 256;local columns=math.ceil(lw/tw)
  for i,file in ipairs(textures) do if i>24 then break end;local col,row=(i-1)%columns,math.floor((i-1)/columns);local w,h=math.min(tw,lw-col*tw),math.min(th,lh-row*th)
   if w>0 and h>0 then local t=f.tiles[i];if not t then t=f:CreateTexture(nil,'BACKGROUND');f.tiles[i]=t end;t:SetTexture(file);t:SetTexCoord(0,w/tw,0,h/th);t:ClearAllPoints();t:SetPoint('TOPLEFT',f,'TOPLEFT',col*tw/lw*340,-row*th/lh*220);t:SetSize(w/lw*340,h/lh*220);t:SetVertexColor(.64,.64,.64,1);t:Show() end
  end
 end
 local info=HP.Call(C_Map and C_Map.GetMapInfo,map);f.caption:SetText((info and info.name or 'Zone')..(task and task.fishing and ' · fishing spot' or ' · suggested surface loop')..(not layer and ' · terrain unavailable' or ''))
 local points=task and task.fishing and {} or routePoints(map,task);for i=2,#points do line(f,i-1,points[i-1].x*340,points[i-1].y*220,points[i].x*340,points[i].y*220,2) end
 local pos=HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,'player');local px,py;if pos then px,py=HP.Call(pos.GetXY,pos) end
 if type(px)=='number' and type(py)=='number' and px>=0 and px<=1 and py>=0 and py<=1 then f.player:ClearAllPoints();f.player:SetPoint('CENTER',f,'TOPLEFT',px*340,-py*220);f.player:Show() else f.player:Hide() end
end
local function clip(x1,y1,x2,y2,r)
 local dx,dy=x2-x1,y2-y1;local a=dx*dx+dy*dy;if a<.001 then return end;local b=2*(x1*dx+y1*dy);local c=x1*x1+y1*y1-r*r;local disc=b*b-4*a*c;if disc<0 then return end
 local t1,t2=(-b-math.sqrt(disc))/(2*a),(-b+math.sqrt(disc))/(2*a);local lo,hi=math.max(0,t1),math.min(1,t2);if lo>hi then return end;return x1+dx*lo,y1+dy*lo,x1+dx*hi,y1+dy*hi
end
-- Native radius follows indoor/outdoor zoom. Older clients expose separate zoom CVars.
function HP.GatherMinimapRadius()
 local radius=HP.Call(C_Minimap and C_Minimap.GetViewRadius)
 if type(radius)=='number' and radius>0 then return radius end
 local zoom=HP.Call(Minimap.GetZoom,Minimap) or 0
 local outdoor=tonumber(HP.Call(GetCVar,'minimapZoom'))
 local sizes=outdoor and outdoor~=zoom and {150,120,90,60,40,25} or {233.333333,200,166.666667,133.333333,100,66.666667}
 return sizes[zoom+1] or sizes[1]
end
local projectedMap,projectedPoints=nil,{}
function HP.GatherMinimapVector()
 local map=HP.GatherCurrentMap and HP.GatherCurrentMap() or HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
 if projectedMap~=map then projectedMap=map;projectedPoints={} end
 local pn,pw,instance=HP.PlayerPoint()
 local player=HP.GatherPosition and HP.GatherPosition(map)
 local width,height=HP.Call(C_Map and C_Map.GetMapWorldSize,map)
 return function(p)
  if pn and pw then
   local key=tostring(p.mapID)..':'..tostring(p.x)..':'..tostring(p.y)
   local cached=projectedPoints[key]
   if not cached then local n,w,i=HP.WorldPoint(p);if n and w then cached={n,w,i};projectedPoints[key]=cached end end
   if cached and cached[3]==instance then return pw-cached[2],cached[1]-pn end
  end
  if player and p.mapID==map and type(width)=='number' and width>0 and type(height)=='number' and height>0 then return (p.x-player.x)*width,(player.y-p.y)*height end
 end
end
function HP.DrawGatherMinimap()
 if HP.gatherOverlay then for _,l in ipairs(HP.gatherOverlay.routeLines or {}) do l:Hide() end;HP.gatherOverlay:Hide() end
 if HP.Suite and (not HP.Suite:On('navigation') or not HP.Suite:On('gathering')) then return end
 local task=HP.auxTask;if not HP.auxiliaryActive or HP.db.guideBook~='professions' or not task or task.training or task.fishing or HP.manualWaypoint or not task.step or not task.step.gather or HP.db.hideRouteLines or HP.db.hideMinimapTrail or HP.db.hidden or HP.db.paused or not Minimap then return end
 if not HP.gatherOverlay then HP.gatherOverlay=CreateFrame('Frame',nil,Minimap);HP.gatherOverlay:SetAllPoints(Minimap);HP.gatherOverlay:SetFrameLevel(Minimap:GetFrameLevel()+19);HP.gatherOverlay:EnableMouse(false) end
 local f=HP.gatherOverlay;local pts=routePoints(task.step.mapID);local radius=HP.GatherMinimapRadius();local vector=HP.GatherMinimapVector()
 local w,h=Minimap:GetWidth(),Minimap:GetHeight();local angle=HP.Call(GetCVar,'rotateMinimap')=='1' and (HP.Call(GetPlayerFacing) or 0) or 0;local previous;local count=0
 for _,p in ipairs(pts) do local dx,dy=vector(p);if dx then local a,b=dx*math.cos(angle)+dy*math.sin(angle),dy*math.cos(angle)-dx*math.sin(angle);local point={a/radius*w/2,-b/radius*h/2}
  if previous then local x1,y1,x2,y2=clip(previous[1],previous[2],point[1],point[2],math.min(w,h)*.47);if x1 then count=count+1;line(f,count,x1+w/2,y1+h/2,x2+w/2,y2+h/2,2) end end;previous=point
 else previous=nil end end;f:Show()
end
local update=HP.UpdateRouteLines
function HP.UpdateRouteLines() update();HP.DrawGatherMinimap() end
