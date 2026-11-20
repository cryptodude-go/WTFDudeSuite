local addonName, HP = ...
-- Native map projection: world vectors are (north, west), in yards.
local function xy(pos)
    if not pos then return end
    local x,y=HP.Call(pos.GetXY,pos)
    if type(x)=="number" and type(y)=="number" then return x,y end
end
function HP.WorldPoint(loc)
    if not loc or not loc.mapID or not CreateVector2D then return end
    local instance,pos=HP.Call(C_Map and C_Map.GetWorldPosFromMapPos,loc.mapID,CreateVector2D(loc.x,loc.y))
    local north,west=xy(pos)
    if north and west then return north,west,instance end
end
function HP.PlayerPoint()
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,"player")
    local x,y=xy(HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,"player"))
    if x then return HP.WorldPoint({mapID=map,x=x,y=y}) end
end
function HP.NavigationVector(loc)
    local n,w,instance=HP.WorldPoint(loc)
    local pn,pw,pi=HP.PlayerPoint()
    if n and pn and instance==pi then return pw-w,n-pn end -- east, north
    -- Same-map fallback for clients temporarily lacking world projection.
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,"player")
    if loc and map==loc.mapID then
        local x,y=xy(HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,"player"))
        local width,height=HP.Call(C_Map and C_Map.GetMapWorldSize,map)
        if x and type(width)=="number" and type(height)=="number" then return (loc.x-x)*width,(y-loc.y)*height end
    end
end
local projection={}
function HP.MapPoint(loc,map)
    if not loc or not map then return end
    if map==loc.mapID then return loc.x,loc.y end
    local n,w,instance=HP.WorldPoint(loc)
    if not n then return end
    local data=projection[map]
    if not data then
        local n0,w0,i0=HP.WorldPoint({mapID=map,x=0,y=0})
        local n1,w1=HP.WorldPoint({mapID=map,x=.5,y=.5})
        if not n0 or not n1 or n0==n1 or w0==w1 then return end
        data={n0,w0,(n1-n0)*2,(w1-w0)*2,i0}; projection[map]=data
    end
    if instance~=data[5] then return end
    return (w-data[2])/data[4],(n-data[1])/data[3]
end
function HP.ItemCount(id)
    return HP.Call(C_Item and C_Item.GetItemCount or GetItemCount,id,false,false) or 0
end
function HP.Vendor(step)
    if step.vendorID then return HP.npcData[step.vendorID] end
    local item=HP.itemData[step.itemID]
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,"player")
    local fallback
    for _,id in ipairs(item and item.vendors or {}) do
        local npc=HP.npcData[id]
        if npc and npc.location then
            fallback=fallback or npc
            if npc.location.mapID==map then return npc end
        end
    end
    return fallback
end
function HP.DestinationName(step)
    local q=HP.questData[step.questID]
    if step.action=="accept" or step.action=="turnin" then
        local npc=q and HP.npcData[step.action=="accept" and q.start or q.finish]
        if npc then return npc.name end
    elseif step.action=="buy" then
        local vendor=HP.Vendor(step); if vendor then return vendor.name end
    elseif step.action=="objective" then
        local objectives=HP.Objectives(step.questID)
        for i,goal in ipairs(q and q.goals or {}) do
            local o=objectives[i]
            if not o or not HP.Public(o.finished) or not o.finished then
                local entity=HP.Entity(goal.kind,goal.id); if entity then return entity.name end
            end
        end
    end
    return step.questID and HP.QuestName(step.questID) or "Guide destination"
end
function HP.BuildGuideRows()
    local route,state=HP.route,HP.state
    local rows,markers={},{}
    HP.markers=markers; HP.areas={}
    if not route or not state then return rows end
    local indices={}; local previous
    for i=1,state.index-1 do if HP.Applies(route.steps[i]) then previous=i end end
    if previous and HP.db.showCompleted then indices[#indices+1]=previous end
    for i=state.index,#route.steps do
        if HP.Applies(route.steps[i]) and (HP.db.showCompleted or (HP.review and i==state.index) or not HP.Done(route.steps[i])) then indices[#indices+1]=i end
        if #indices>=math.max(13,math.ceil(((HP.frame and HP.frame:GetHeight() or 340)-150)/28)+5) then break end
    end
    if route.catalog then
        indices={};if route.steps[state.index] and (HP.db.showCompleted or HP.review or not HP.Done(route.steps[state.index])) then indices[1]=state.index end
        for _,candidate in ipairs(HP.PlanCandidates(route,state.skipped)) do if candidate.index~=state.index then indices[#indices+1]=candidate.index end;if #indices>=math.max(2,math.ceil(((HP.frame and HP.frame:GetHeight() or 250)-150)/36)) then break end end
    end
    local grouped={}; local upcoming=false
    for _,i in ipairs(indices) do
        local step=route.steps[i]; local done=HP.Done(step)
        local loc=HP.StepLocation(step)
        if i==state.index and step.action=="objective" and not HP.Active(step.questID) then
            local q=HP.questData[step.questID]; local npc=q and HP.npcData[q.start]
            loc=npc and npc.location
        end
        local number
        if loc and not done and (route.catalog or i>=state.index) then
            local key=string.format("%d:%.4f:%.4f",loc.mapID,loc.x,loc.y)
            local marker=grouped[key]
            if not marker then
                number=#markers+1
                marker={number=number,location=loc,titles={},stepIndex=i,name=HP.DestinationName(step)}
                markers[#markers+1]=marker; grouped[key]=marker
            end
            number=marker.number
            marker.titles[#marker.titles+1]=(step.action=="buy" and "Buy "..(HP.itemData[step.itemID] and HP.itemData[step.itemID].name or "item")) or (step.questID and HP.QuestName(step.questID)) or ("Reach level "..(step.targetLevel or ""))
        end
        local prefix=number and ("|cffffffff"..number..".|r ") or ""
        if i==state.index or (i==previous and done) then
            if loc then
                local map=HP.Call(C_Map and C_Map.GetMapInfo,loc.mapID)
                local zone=map and HP.Public(map.name) and map.name or ({[1411]="Durotar",[1412]="Mulgore",[1420]="Tirisfal Glades",[1454]="Orgrimmar"})[loc.mapID] or "Destination"
                local phase=HP.QuestStepPhase(step);local destination=(phase.action=='accept' or phase.action=='turnin') and HP.DestinationName(phase)
                local city=({[1454]=true,[1456]=true,[1458]=true})[loc.mapID]
                local travelName=destination and destination~=zone and (city and zone..' · talk to '..destination or destination..' · '..zone) or zone
                rows[#rows+1]={kind="travel",text=prefix.."Go to |cffffd68a"..travelName..string.format(" %.1f, %.1f|r",loc.x*100,loc.y*100),location=loc,stepIndex=i,done=done or HP.HasArrived(loc,i)}
            end
            if step.hint and not done and not HP.db.hideTips then rows[#rows+1]={kind="tip",text=step.hint,indent=24,location=loc,stepIndex=i} end
            for _,row in ipairs(HP.StepRows(step)) do
                row.location=loc; row.stepIndex=i; row.current=true
                if done then row.done=true end
                if not (done and row.kind=="tip") then rows[#rows+1]=row end
            end
        else
            if (route.catalog or i>state.index) and not upcoming then rows[#rows+1]={kind="section",text="UP NEXT",indent=0}; upcoming=true end
            local compact=HP.StepRows(step,true)
            for j,row in ipairs(compact) do
                row.text=(j==1 and prefix or "")..row.text
                row.location=loc; row.stepIndex=i; row.skipped=state.skipped[i]
                if done then row.done=true end
                rows[#rows+1]=row
            end
        end
    end
    local step=route.steps[state.index]
    if step then step=HP.QuestStepPhase(step) end
    if step and step.action=="objective" and HP.Active(step.questID) then
        local q=HP.questData[step.questID]; local objectives=HP.Objectives(step.questID); local seen={}
        local function addEntity(entity,name)
            for _,point in ipairs(entity and entity.spawns or {}) do
                local key=string.format("%d:%.3f:%.3f",point.mapID,point.x,point.y)
                if not seen[key] and #HP.areas<100 then
                    seen[key]=true; HP.areas[#HP.areas+1]={location=point,title=name}
                end
            end
        end
        for i,goal in ipairs(q and q.goals or {}) do
            local o=objectives[i]
            if not o or not HP.Public(o.finished) or not o.finished then
                local entity=HP.Entity(goal.kind,goal.id)
                if goal.kind=="item" then
                    for _,id in ipairs(entity and entity.mobs or {}) do addEntity(HP.npcData[id],entity.name) end
                    for _,id in ipairs(entity and entity.objects or {}) do addEntity(HP.objectData[id],entity.name) end
                else addEntity(entity,entity and entity.name) end
            end
        end
    end
    return rows
end
local function pin(parent,area)
    local f=CreateFrame("Button",nil,parent); f:SetSize(area and 18 or 24,area and 18 or 24); f:SetFrameLevel(parent:GetFrameLevel()+(area and 1 or 4))
    f.bg=f:CreateTexture(nil,"ARTWORK"); f.bg:SetAllPoints()
    f.bg:SetTexture("Interface\\AddOns\\"..addonName.."\\Media\\Circle")
    f.bg:SetVertexColor(area and .9 or .1,area and .25 or .1,area and .08 or .1,area and .30 or .22)
    if not area then
        f.label=f:CreateFontString(nil,"OVERLAY"); f.label:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE"); f.label:SetAllPoints(); f.label:SetTextColor(1,1,1); f.label:SetShadowColor(0,0,0,1); f.label:SetShadowOffset(1,-1)
        f:RegisterForClicks("LeftButtonUp","RightButtonUp")
        f:SetScript("OnClick",function(self,button)
            HP.manualWaypoint=button~="RightButton" and self.data.location or nil; HP.Refresh()
        end)
    end
    f:SetScript("OnEnter",function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:SetText(area and ("Objective area: "..(self.data.title or "")) or table.concat(self.data.titles,"\n"))
        GameTooltip:AddLine(area and "Known Classic spawn locations; Forever may differ." or "Left-click: navigate. Right-click: resume guide.",1,1,1,true)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    return f
end
local pins={mini={},world={},areaMini={},areaWorld={}}
local outdoor={466.6667,400,333.3333,266.6667,200,133.3333}
local indoor={300,240,180,120,80,50}
local function separateNumber(occupied,x,y,halfWidth,halfHeight)
    local function clear(cx,cy)
        for _,p in ipairs(occupied) do if (cx-p[1])^2+(cy-p[2])^2<18^2 then return false end end
        return true
    end
    local cx,cy=x,y
    if not clear(cx,cy) then
        for attempt=1,40 do
            local angle=attempt*2.39996323; local radius=7*math.sqrt(attempt)
            local tx,ty=x+math.cos(angle)*radius,y+math.sin(angle)*radius
            if (tx/halfWidth)^2+(ty/halfHeight)^2<.9^2 and clear(tx,ty) then cx,cy=tx,ty; break end
        end
    end
    occupied[#occupied+1]={cx,cy}; return cx,cy
end
function HP.UpdateMapPins()
    if HP.UpdateRouteLines then HP.UpdateRouteLines() end
    local canvas=HP.MapCanvas(WorldMapFrame)
    local map=WorldMapFrame and HP.Call(WorldMapFrame.GetMapID,WorldMapFrame)
    local radius=HP.Call(C_Minimap and C_Minimap.GetViewRadius)
    if type(radius)~="number" or radius<=0 then
        local zoom=HP.Call(Minimap and Minimap.GetZoom,Minimap) or 0
        local inside=HP.Call(GetCVar,"minimapZoom")
        radius=((tonumber(inside)==zoom and outdoor or indoor)[zoom+1] or 466.6667)/2
    end
    local facing=HP.Call(GetPlayerFacing) or 0
    local rotate=HP.Call(GetCVar,"rotateMinimap")=="1"
    local enabled=HP.db and not HP.db.hidden and not HP.db.paused and not HP.demo
    for _,set in ipairs({{HP.markers or {},pins.mini,pins.world,false},{HP.areas or {},pins.areaMini,pins.areaWorld,true}}) do
        local data,mini,world,area=unpack(set); local occupied={}
        for _,p in ipairs(mini) do p.activeThisTick=false end; for _,p in ipairs(world) do p.activeThisTick=false end
        if enabled and (area or not HP.db.hideMapNumbers) then for i,d in ipairs(data) do
            local dx,dy=HP.NavigationVector(d.location)
            if dx and Minimap and Minimap:IsShown() and (area or not HP.db.hideMinimapNumbers) then
                if rotate then local x,y=dx,dy; dx=x*math.cos(facing)+y*math.sin(facing); dy=y*math.cos(facing)-x*math.sin(facing) end
                local distance=math.sqrt(dx*dx+dy*dy)
                if not area or distance<radius*.85 then
                    if distance>radius*.83 then dx,dy=dx*radius*.83/distance,dy*radius*.83/distance end
                    if not mini[i] then mini[i]=pin(Minimap,area) end
                    local p=mini[i]; p.data=d; p.activeThisTick=true
                    if not area then p.label:SetText(d.number); if HP.db.pinCircles then p.bg:Show() else p.bg:Hide() end end
                    local sx,sy=dx/radius*Minimap:GetWidth()/2,dy/radius*Minimap:GetHeight()/2
                    if not area then sx,sy=separateNumber(occupied,sx,sy,Minimap:GetWidth()/2,Minimap:GetHeight()/2) end
                    p:ClearAllPoints(); p:SetPoint("CENTER",Minimap,"CENTER",sx,sy); p:Show()
                end
            end
            if canvas and WorldMapFrame:IsShown() then
                local x,y=HP.MapPoint(d.location,map)
                if x and x>=0 and x<=1 and y>=0 and y<=1 then
                    if not world[i] then world[i]=pin(canvas,area) end
                    local p=world[i]; p.data=d; p.activeThisTick=true
                    if not area then p.label:SetText(d.number); if HP.db.pinCircles then p.bg:Show() else p.bg:Hide() end end
                    p:ClearAllPoints(); p:SetPoint("CENTER",canvas,"TOPLEFT",x*canvas:GetWidth(),-y*canvas:GetHeight()); p:Show()
                end
            end
        end end
        for _,p in ipairs(mini) do if not p.activeThisTick then p:Hide() end end
        for _,p in ipairs(world) do if not p.activeThisTick then p:Hide() end end
    end
end

