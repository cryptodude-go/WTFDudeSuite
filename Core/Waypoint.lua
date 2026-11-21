local addonName, HP = ...
local sample
function HP.ArrivalEstimate(w,distance)
    local target=table.concat({w.mapID,w.x,w.y},":"); local now=HP.Call(GetTime) or 0
    if not sample or sample.key~=target then sample={key=target,time=now,distance=distance}; return "--:--" end
    if now-sample.time>=1 then
        local rate=(sample.distance-distance)/(now-sample.time)
        sample.rate=rate>0.2 and (sample.rate and (sample.rate+rate)/2 or rate) or nil
        sample.time=now; sample.distance=distance
    end
    if not sample.rate then return "--:--" end
    local seconds=math.min(59999,math.ceil(distance/sample.rate))
    return string.format("%d:%02d",math.floor(seconds/60),seconds%60)
end
function HP.MapCanvas(frame)
    if not frame then return end
    local canvas=type(frame.GetCanvas)=="function" and HP.Call(frame.GetCanvas,frame)
    if type(canvas)=="table" or type(canvas)=="userdata" then return canvas end
    local scroll=frame.ScrollContainer
    if type(scroll)=="table" or type(scroll)=="userdata" then return scroll.Child end
end
function HP.NavigationInstruction(fallback)
    if HP.manualWaypoint then return fallback end
    if HP.db.mode=="quests" then return HP.db.questID and "Go to "..HP.QuestName(HP.db.questID) or fallback end
    local step=HP.route and HP.state and HP.route.steps[HP.state.index]
    if not step then return fallback end
    step=HP.QuestStepPhase(step)
    local name=HP.DestinationName(step) or fallback
    if step.action=="accept" or step.action=="turnin" then return "Talk to "..name end
    if step.action=="buy" then return "Visit "..name end
    return step.navigationText or "Go to "..name
end
function HP.NavigationAction()
    if HP.manualWaypoint then return "Manual destination" end
    if HP.db.mode=="quests" then return HP.db.questID and HP.QuestName(HP.db.questID) or "" end
    local step=HP.route and HP.state and HP.route.steps[HP.state.index]
    if step then step=HP.QuestStepPhase(step) end
    if not step then return HP.db.questID and HP.QuestName(HP.db.questID) or "" end
    local name=step.questID and HP.QuestName(step.questID) or ""
    if step.action=="accept" then return "Accept '"..name.."'" end
    if step.action=="turnin" then return "Turn in '"..name.."'" end
    local rows=HP.StepRows(step,true)
    for _,row in ipairs(rows) do if not row.done then return row.text end end
    return "Step completed"
end
local function arrivalKey(i,loc) return (HP.routeID or "guide")..":"..(HP.route and HP.route.revision or 0)..":"..i..":"..loc.mapID..":"..loc.x..":"..loc.y end
function HP.HasArrived(loc,i)
    if not loc then return false end
    if HP.Done(HP.route.steps[i]) then return true end
    HP.db.arrivals=HP.db.arrivals or {}
    if HP.db.arrivals[arrivalKey(i,loc)] then return true end
    local dx,dy=HP.NavigationVector(loc)
    if dx and dx*dx+dy*dy<=15*15 then HP.db.arrivals[arrivalKey(i,loc)]=true; return true end
    return false
end
function HP.CheckArrival()
    if HP.manualWaypoint or not HP.route or not HP.state or HP.db.mode=="quests" then return end
    local i=HP.state.index;local step=HP.route.steps[i];local loc=step and HP.waypoint
    if not loc or HP.Done(step) then return end
    HP.db.arrivals=HP.db.arrivals or {}
    local key=arrivalKey(i,loc)
    if not HP.db.arrivals[key] and HP.HasArrived(loc,i) then HP.Refresh() end
end
function HP.SetArrowHeading(angle,distance)
    local a=HP.arrow;local frame=math.floor(((angle%(2*math.pi))/(2*math.pi))*64+.5)%64
    local col,row=frame%8,math.floor(frame/8)
    a.texture:SetRotation(0)
    a.texture:SetTexCoord(col/8,(col+1)/8,row/8,(row+1)/8)
    -- A subtle arrival pulse, using original shaded perspective sprites.
    local pulse=distance<15 and (1+.06*math.sin((HP.Call(GetTime) or 0)*4)) or 1
    a.texture:SetSize(72*pulse,72*pulse)
end
function HP.StrikeRow(row,done,height,size)
    if type(row.strikes)~="table" then row.strikes={} end
    for _,line in ipairs(row.strikes) do line:Hide() end
    if not done or HP.db.noStrike then return end
    local measured=HP.Call(row.text.GetStringWidth,row.text) or row.text:GetWidth()
    local width=math.min(measured,row.text:GetWidth())
    local count=math.max(1,math.ceil((row.text:GetStringHeight() or size)/(size+2)))
    for i=1,count do
        local line=row.strikes[i]
        if not line then line=row:CreateTexture(nil,"OVERLAY");line:SetTexture("Interface\\Buttons\\WHITE8X8");row.strikes[i]=line end
        line:ClearAllPoints();line:SetPoint("TOPLEFT",row.text,"TOPLEFT",0,-size*.55-(i-1)*(size+2))
        line:SetSize(width,1);line:SetVertexColor(.58,.65,.58,.8);line:Show()
    end
end

function HP.CoordinateText(destination)
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,"player")
    local pos=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,"player")
    local x,y
    -- Keep multiple returns intact (and do not format secret client values).
    if pos then x,y=HP.Call(pos.GetXY,pos) end
    local name=map and HP.Call(C_Map and C_Map.GetMapInfo,map)
    local zone=name and HP.Public(name.name) and name.name or "Current zone"
    local here=type(x)=="number" and type(y)=="number" and string.format("You: %s %.1f, %.1f",zone,x*100,y*100) or "You: coordinates unavailable"
    local targetMap=HP.Call(C_Map and C_Map.GetMapInfo,destination.mapID)
    local targetZone=targetMap and HP.Public(targetMap.name) and targetMap.name or "Destination"
    if map==destination.mapID and type(x)=="number" and type(y)=="number" then
        return string.format("You: %.1f, %.1f   |   To: %.1f, %.1f",x*100,y*100,destination.x*100,destination.y*100)
    end
    return here.."\n"..string.format("To: %s %.1f, %.1f",targetZone,destination.x*100,destination.y*100)
end
