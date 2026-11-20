local HP = _G.WTFDudeSuiteRuntime
local D = HP.Native
local A = D.Arrow

local function mapKey(name)
    return name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " "):lower()
end

local mapsByName
local function findNamedMap(name)
    if not mapsByName then
        mapsByName = {}
        local seen = {}
        local function add(map, name)
            if type(map) ~= "number" or map < 1 or not HP.Public(name) or type(name) ~= "string" or name == "" then return end
            local key = mapKey(name)
            local previous = mapsByName[key]
            if previous == nil then
                mapsByName[key] = map
            elseif previous ~= map then
                mapsByName[key] = false
            end
        end
        local function scan(map)
            if seen[map] then return end
            seen[map] = true
            add(map, D.Compat.MapName(map))
        end
        -- Include the client's localized names and the Suite's known Forever zones.
        local mapChildren = C_Map and C_Map.GetMapChildrenInfo
        for _, root in ipairs({ 947, 1414, 1415 }) do
            scan(root)
            local children = HP.Call(mapChildren, root, nil, true)
            for _, info in ipairs(type(children) == "table" and children or {}) do
                local map = info.mapID
                if HP.Public(map) and type(map) == "number" then
                    add(map, info.name)
                    seen[map] = true
                end
            end
        end
        D.Data:ForEachUiMap(scan)
        for _, zone in ipairs(HP.zoneCatalog or {}) do
            add(zone.mapID, zone.name)
            if zone.mapID then scan(zone.mapID) end
        end
    end
    local key = mapKey(name)
    local map = mapsByName[key]
    if map ~= nil then return map end
    local current = D.Compat.PlayerMap()
    local currentName = current and D.Compat.MapName(current)
    if currentName and mapKey(currentName) == key then return current end
end

local function readCoordinates(args)
    return (args .. " "):match("^([%d.]+)%s*[%s,]%s*([%d.]+)%s+(.-)%s*$")
end

local function parse(args)
    local mapID, rest = args:match("^(%d+)%s+(.+)$")
    if mapID and tonumber(mapID) > 100 then
        local x, y, label = readCoordinates(rest)
        if x then return mapID, x, y, label end
    end
    local x, y, label = readCoordinates(args)
    if x then
        -- Preserve the three-number syntax for valid low-numbered map IDs.
        if mapID and label:match("^[%d.]+$") and D.Compat.MapName(tonumber(mapID)) then
            local mx, my = readCoordinates(rest)
            if mx then return mapID, mx, my, "" end
        end
        return "", x, y, label
    end
    return (args .. " "):match("^(.-)%s+([%d.]+)%s*[%s,]%s*([%d.]+)%s+(.-)%s*$")
end

local function redraw()
    A.point, A.shownPoint, A.follow, A.farm = nil, nil, nil, nil
    A:Update()
    D.MinimapPins:Update()
    HP.UpdateRouteLines()
end

local function clear()
    if not A.manualPoint then return end
    A.manualPoint = nil
    A.point, A.shownPoint, A.follow, A.farm = nil, nil, nil, nil
    HP.Refresh()
    D.MinimapPins:Update()
    D:Print("Manual waypoint cleared.")
end

local function command(input)
    if not HP.nativeStarted or not D.db then return end
    if input:lower():match("^%s*clear%s*$") then return clear() end
    if not HP.Suite:On("navigation") then
        D:Print("Enable Arrow & maps to use waypoints.")
        return
    end
    local args = input:match("^%s*(.-)%s*$")
    local zoneInput, x, y, label = parse(args)
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x < 0 or x > 100 or y < 0 or y > 100 then
        D:Print("Use /wtf way 40.6, 52.4 or /wtf way Loch Modan 49.4 12.9 Loch Modan Dam. To clear: /wtf clearway.")
        return
    end
    local map
    if zoneInput == "" then
        map = D.Compat.PlayerMap()
    else
        map = tonumber(zoneInput)
        if not map then map = findNamedMap(zoneInput) end
        if map == false then
            D:Print(("More than one map is named %s. Specify a map ID."):format(zoneInput))
            return
        end
    end
    local zone = map and D.Compat.MapName(map)
    if not zone then
        D:Print(zoneInput == "" and "Current map unavailable. Enter a zone name or map ID."
            or ("Map unavailable: %s. Check the zone name or specify a map ID."):format(zoneInput))
        return
    end
    if label == "" then label = ("Waypoint %s, %s"):format(x, y) end
    A.manualPoint = { map = map, x = x, y = y, label = label, location = { mapID = map, x = x / 100, y = y / 100 } }
    redraw()
    D:Print(("%s (%s)."):format(label, zone))
end

local nativeCommand = SlashCmdList.DWMGDING
SlashCmdList.DWMGDING = function(input)
    local key, rest = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
    key = key:lower()
    if key == "way" then return command(rest) end
    if key == "clearway" and rest == "" then return clear() end
    return nativeCommand(input)
end

-- Preserve /way for any addon that has already registered it during loading.
D:On("PLAYER_LOGIN", function()
    for key, value in pairs(_G) do
        if type(key) == "string" and key:match("^SLASH_") and value == "/way" then return end
    end
    SlashCmdList.WTFDUDEWAY = function(input) command(input or "") end
    SLASH_WTFDUDEWAY1 = "/way"
end)

-- Draw an overlay on the world map so the manual pin also works on maps where
-- the client rejects SetUserWaypoint, or when the player has a Blizzard pin.
local pin, placedPoint, placedMap, placedWidth, placedHeight
local function updateWorldPin()
    local point = A.manualPoint
    local mapFrame = WorldMapFrame
    if not point or not mapFrame or not mapFrame:IsShown() then
        if pin and pin:IsShown() then pin:Hide() end
        return
    end
    local canvas = HP.MapCanvas(mapFrame)
    local map = HP.Call(mapFrame.GetMapID, mapFrame)
    if not canvas or not map then
        if pin then pin:Hide() end
        return
    end
    local width, height = canvas:GetWidth(), canvas:GetHeight()
    if point == placedPoint and map == placedMap and pin and pin:GetParent() == canvas
        and width == placedWidth and height == placedHeight then
        if not pin:IsShown() then pin:Show() end
        return
    end
    local x, y = HP.MapPoint(point.location, map)
    if not x or x < 0 or x > 1 or y < 0 or y > 1 then
        if pin then pin:Hide() end
        placedPoint = nil
        return
    end
    if not pin then
        pin = CreateFrame("Frame", nil, canvas)
        pin:SetSize(22, 22)
        local icon = D.UI.Icon(pin, "ring", 22, D.UI.C.accent, "OVERLAY")
        icon:SetPoint("CENTER")
        local dot = D.UI.Icon(pin, "circle", 6, D.UI.C.accent, "OVERLAY")
        dot:SetPoint("CENTER")
        if pin.SetMouseClickEnabled and GameTooltip then
            pin:EnableMouse(true)
            pin:SetMouseClickEnabled(false)
            pin:SetScript("OnEnter", function(self)
                local active = A.manualPoint
                if not active then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(active.label)
                GameTooltip:AddLine(("%s, %s"):format(active.x, active.y))
                GameTooltip:Show()
            end)
            pin:SetScript("OnLeave", function(self)
                if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
            end)
            pin:SetScript("OnHide", function(self)
                if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
            end)
        end
    elseif pin:GetParent() ~= canvas then
        pin:SetParent(canvas)
    end
    pin:SetFrameLevel(canvas:GetFrameLevel() + 24)
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", canvas, "TOPLEFT", x * width, -y * height)
    pin:Show()
    placedPoint, placedMap, placedWidth, placedHeight = point, map, width, height
end

local updateRouteLines = HP.UpdateRouteLines
function HP.UpdateRouteLines(...)
    updateRouteLines(...)
    updateWorldPin()
end
