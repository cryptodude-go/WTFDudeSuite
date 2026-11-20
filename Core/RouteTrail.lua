local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local world,mini
local worlds={}
local function overlay(parent)
    local f=CreateFrame('Frame',nil,parent);f:SetAllPoints(parent);f:SetFrameLevel(parent:GetFrameLevel()+20);f:EnableMouse(false)
    f.lines={};f.dots={};f.trailParent=parent;return f
end
local function hide(f)
    if not f then return end
    for _,l in ipairs(f.lines) do l:Hide() end
    for _,d in ipairs(f.dots) do d:Hide() end
    f:Hide()
end
local function dot(f,i,x,y,size)
    local d=f.dots[i]
    if not d then d=f:CreateTexture(nil,'OVERLAY');d:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\Circle');f.dots[i]=d end
    d:ClearAllPoints();d:SetPoint('CENTER',f,'TOPLEFT',x,y);d:SetSize(size,size);d:SetVertexColor(1,.94,.30,1);d:Show()
end
function HP.TrailPoints()
    local points={}
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
    local pos=map and HP.Call(C_Map.GetPlayerMapPosition,map,'player')
    if pos then local x,y=HP.Call(pos.GetXY,pos);if type(x)=='number' and type(y)=='number' then points[1]={mapID=map,x=x,y=y} end end
    local function add(p)
        if not p or type(p.x)~='number' or type(p.y)~='number' then return end
        local prev=points[#points];if not prev or prev.mapID~=p.mapID or math.abs(prev.x-p.x)+math.abs(prev.y-p.y)>.0001 then points[#points+1]=p end
    end
    if HP.waypoint then
        -- Authored walking points, when available, belong to the current step only.
        local step=HP.route and HP.state and HP.route.steps[HP.state.index]
        for _,p in ipairs(not HP.manualWaypoint and step and step.path or {}) do add(p) end
        add(HP.waypoint)
    end
    if not HP.manualWaypoint then
        for _,m in ipairs(HP.markers or {}) do if #points>=24 then break end;if not HP.state or (m.stepIndex or HP.state.index)>=HP.state.index then add(m.location) end end
    end
    return points
end
function HP.UpdateRouteLines()
    hide(world);hide(mini)
    if HP.Suite and not HP.Suite:CanNavigate() then return end
    local manual=HP.Native.Arrow.manualPoint
    if not HP.db or (not manual and (HP.db.hidden or HP.db.paused)) or HP.db.hideRouteLines or HP.demo then return end
    local phase=HP.db.staticRouteTrail and 0 or ((HP.Call(GetTime) or 0)*24)%22
    local canvas=HP.MapCanvas(WorldMapFrame)
    if canvas and WorldMapFrame:IsShown() then
        if not world or world.trailParent~=canvas then world=worlds[canvas] or overlay(canvas);worlds[canvas]=world;HP.trailWorld=world end
        world:Show();local map=HP.Call(WorldMapFrame.GetMapID,WorldMapFrame);local points=HP.TrailPoints();local used=0
        for i=2,#points do
            local ax,ay=HP.MapPoint(points[i-1],map);local bx,by=HP.MapPoint(points[i],map)
            if ax and bx and ax>=0 and ax<=1 and ay>=0 and ay<=1 and bx>=0 and bx<=1 and by>=0 and by<=1 then
                ax,ay,bx,by=ax*canvas:GetWidth(),-ay*canvas:GetHeight(),bx*canvas:GetWidth(),-by*canvas:GetHeight()
                local length=math.sqrt((bx-ax)^2+(by-ay)^2)
                if length>1 then
                    do
                        for distance=phase%math.min(22,length),length,22 do if used>=320 then break end;used=used+1;local t=distance/length;dot(world,used,ax+(bx-ax)*t,ay+(by-ay)*t,5) end
                    end
                end
            end
        end
    end
    if HP.db.hideMinimapTrail or not Minimap or not Minimap:IsShown() or not HP.waypoint then return end
    local dx,dy=HP.NavigationVector(HP.waypoint);if not dx then return end
    local radius=HP.Call(C_Minimap and C_Minimap.GetViewRadius)
    if type(radius)~='number' or radius<=0 then
        local outdoor={466.6667,400,333.3333,266.6667,200,133.3333};local indoor={300,240,180,120,80,50}
        local zoom=HP.Call(Minimap.GetZoom,Minimap) or 0;local inside=tonumber(HP.Call(GetCVar,'minimapZoom'))==zoom
        radius=((inside and outdoor or indoor)[zoom+1] or 466.6667)/2
    end
    if HP.Call(GetCVar,'rotateMinimap')=='1' then local facing=HP.Call(GetPlayerFacing) or 0;local x,y=dx,dy;dx=x*math.cos(facing)+y*math.sin(facing);dy=y*math.cos(facing)-x*math.sin(facing) end
    local length=math.sqrt(dx*dx+dy*dy);if length<1 then return end
    local fraction=math.min(1,radius*.78/length);dx,dy=dx*fraction,dy*fraction
    if not mini then mini=overlay(Minimap);HP.trailMini=mini end
    mini:Show();local cx,cy=Minimap:GetWidth()/2,-Minimap:GetHeight()/2
    local tx,ty=cx+dx/radius*Minimap:GetWidth()/2,cy+dy/radius*Minimap:GetHeight()/2
    do local pixels=math.sqrt((tx-cx)^2+(ty-cy)^2);local count=0;for distance=(pixels>0 and phase%math.min(22,pixels) or 0),pixels,22 do count=count+1;local t=distance/pixels;dot(mini,count,cx+(tx-cx)*t,cy+(ty-cy)*t,4) end end
end
