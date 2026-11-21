local HP = _G.WTFDudeSuiteRuntime
local D = HP.Native
local cache = {}
local skills = { Herbalism = 182, Mining = 186, Fishing = 356 }
local flags = { Herbalism = "gatherHerbNodes", Mining = "gatherMineNodes", Fishing = "gatherFishNodes" }

function HP.HasGatherDisplay(allProfessions)
    if not HP.db or HP.db.gatherShowNodes == false then return false end
    local professions = HP.ProfessionSkills()
    for kind, skillID in pairs(skills) do
        if HP.db[flags[kind]] ~= false and (allProfessions or HP.db.gatherAllProfessions or professions[skillID]) then return true end
    end
    return false
end


function HP.GatherWorldIconScale(overlay)
    local mapScale=HP.Call(WorldMapFrame and WorldMapFrame.GetEffectiveScale,WorldMapFrame)
    local canvasScale=HP.Call(overlay.GetEffectiveScale,overlay)
    if type(mapScale)=='number'and type(canvasScale)=='number'and mapScale>0 and canvasScale>0 then
        return math.max(.05,math.min(20,mapScale/canvasScale))
    end
    local zoom=HP.Call(WorldMapFrame and WorldMapFrame.GetCanvasScale,WorldMapFrame)
    if type(zoom)=='number'and zoom>0 then return math.max(.05,math.min(20,1/zoom))end
    return 1
end

function HP.GatherDisplayNodes(map, allProfessions)
    if not map or not HP.db then return {} end
    local professions = HP.ProfessionSkills()
    local enabled, mask = {}, {}
    for kind, skillID in pairs(skills) do
        if HP.db[flags[kind]] ~= false and (allProfessions or HP.db.gatherAllProfessions or professions[skillID]) then
            enabled[kind] = true
            mask[#mask + 1] = kind
        end
    end
    table.sort(mask)
    local key = map .. ":" .. table.concat(mask, ",") .. ":" .. tostring(HP.gatherRevision or 0)
    if cache[key] then return cache[key] end
    local nodes, byPosition = {}, {}
    local function add(x, y, id, observed, source)
        local info = HP.gatherNodeInfo[id]
        if not info or not enabled[info.kind] or type(x) ~= "number" or type(y) ~= "number"
            or x <= 0 or x >= 1 or y <= 0 or y >= 1 then return end
        local position = ("%d:%.3f:%.3f"):format(id, x, y)
        local previous = byPosition[position]
        if previous then
            if observed then previous.observed = true end
            return
        end
        local entry = { mapID = map, x = x, y = y, id = id, observed = observed, source = source }
        nodes[#nodes + 1] = entry
        byPosition[position] = entry
    end
    if HP.db.gatherReferenceNodes ~= false then
        for _, point in ipairs(HP.gatherSeeds[map] or {}) do
            add(point[1], point[2], point[3], false,
                point[4] == 1 and "Forever reference" or "Classic gathering database")
        end
    end
    for _, point in ipairs(HP.db.gatherNodes and HP.db.gatherNodes[map] or {}) do
        add(point.x, point.y, point.id, true, "Gathered by you")
    end
    local count = 0
    for _ in pairs(cache) do count = count + 1 end
    if count >= 8 then cache = {} end
    cache[key] = nodes
    return nodes
end

HP.Defer(30, "gathering-map-settings", function()
    local C, UI = D.Config, D.UI
    local build = C.TABS[C.TAB.gathering].build
    C.TABS[C.TAB.gathering].build = function(canvas, width)
        local rows = build(canvas, width)
        rows[#rows + 1] = UI.HeaderRow(canvas, "Resource circles", width)
        for _, option in ipairs({
            { "Show circles on the world map", "gatherWorldNodes", true },
            { "Show all professions on the world map", "gatherWorldAllProfessions", true },
            { "Show circles on the minimap", "gatherMinimapNodes", true },
            { "Show herbs", "gatherHerbNodes", true },
            { "Show ore veins", "gatherMineNodes", true },
            { "Show fishing pools", "gatherFishNodes", true },
            { "Include professions I have not learned", "gatherAllProfessions", false },
            { "Include the built-in node database", "gatherReferenceNodes", true },
        }) do
            local label, key, default = unpack(option)
            rows[#rows + 1] = UI.CheckRow(canvas, C, {
                label = label, default = default,
                get = function()
                    if HP.db[key] == nil then return default end
                    return HP.db[key] == true
                end,
                set = function(value)
                    HP.db[key] = value
                    cache = {}
                    HP.InvalidateGathering()
                    HP.UpdateGatherWorldNodes()
                    HP.DrawGatherMinimap()
                    HP.Performance:Reconcile()
                end,
            }, width)
        end
        rows[#rows + 1] = UI.InfoRow(canvas,
            "Circles work while questing, with the guide closed or paused. The world map can show all professions in the selected zone. Minimap filters follow your learned professions unless enabled separately. Green marks your own harvests, lime marks herbs, gold marks ore, and blue marks fishing pools. Click a circle to navigate. Reference locations may differ on changed Forever maps.",
            width)
        rows[#rows + 1] = UI.ButtonRow(canvas, C, {
            label = "Fishing 1–300", button = "Open guide",
            run = function() HP.db.professionGuide = "Fishing"; HP.ChooseGuideBook("professions") end,
        }, width)
        return rows
    end
end)

local attachedMap
function HP.AttachGatherWorldMap()
    local map = WorldMapFrame
    if not map or attachedMap == map then return end
    attachedMap = map
    local function refresh()
        HP.UpdateGatherWorldNodes()
        if HP.Performance then HP.Performance:Reconcile() end
    end
    map:HookScript("OnShow", refresh)
    map:HookScript("OnHide", refresh)
    map:HookScript("OnSizeChanged", refresh)
    if type(hooksecurefunc) == "function" and type(map.OnMapChanged) == "function" then
        hooksecurefunc(map, "OnMapChanged", refresh)
    end
end
D:On("PLAYER_LOGIN", function() HP.AttachGatherWorldMap() end)
D:On("ADDON_LOADED", function() HP.AttachGatherWorldMap() end)
