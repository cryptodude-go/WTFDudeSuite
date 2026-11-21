local _, HP = ...
local D = HP.Native
local Q = {}
HP.MapQuestCounter = Q

local function number(value)
    return HP.Public(value) and type(value) == "number" and value >= 0 and value < 10000
end

function Q:Counts()
    local api = C_QuestLog or {}
    local entries, count = HP.Call(api.GetNumQuestLogEntries)
    if not number(count) then
        local legacyEntries, legacyCount = HP.Call(GetNumQuestLogEntries)
        if number(legacyCount) then count = legacyCount end
        if not number(entries) then entries = legacyEntries end
    end
    if not number(count) and number(entries) and type(api.GetInfo) == "function" then
        count = 0
        for i = 1, math.min(entries, 1000) do
            local info = HP.Call(api.GetInfo, i)
            if type(info) == "table" and HP.Public(info.isHeader) and not info.isHeader
                and number(info.questID) and info.questID > 0 then count = count + 1 end
        end
    end
    local maximum = HP.Call(api.GetMaxNumQuestsCanAccept)
    if not number(maximum) or maximum < 1 then maximum = MAX_QUESTLOG_QUESTS end
    if not number(maximum) or maximum < 1 then maximum = 40 end
    return number(count) and math.floor(count) or nil, math.floor(maximum)
end

local function frame(value)
    local kind = type(value)
    return (kind == "table" or kind == "userdata") and type(value.IsShown) == "function"
end

function Q:Update()
    local map = WorldMapFrame
    if not map or not D.db or not HP.Suite:On("suite") or D.db.ui.mapQuestCounter == false or not map:IsShown() then
        if self.badge then self.badge:Hide() end
        return
    end
    local panel = frame(QuestMapFrame) and QuestMapFrame or frame(map.QuestLog) and map.QuestLog
    if panel and not panel:IsShown() then
        if self.badge then self.badge:Hide() end
        return
    end
    local f = self.badge
    if not f then
        f = CreateFrame("Frame", nil, map)
        self.badge = f
        f:SetSize(164, 22)
        f:EnableMouse(false)
        f.look = D.UI.Window(f, "dialog")
        f.text = D.UI.Text(f, "semibold", 12, D.UI.C.text)
        f.text:SetPoint("CENTER")
    end
    if f:GetParent() ~= map then f:SetParent(map) end
    local anchor = panel or map
    if self.anchor ~= anchor then
        f:ClearAllPoints()
        if panel then
            f:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", -8, 3)
        else
            f:SetPoint("TOPRIGHT", map, "TOPRIGHT", -76, -8)
        end
        self.anchor = anchor
    end
    f:SetFrameLevel(math.max(map:GetFrameLevel(), anchor:GetFrameLevel()) + 30)
    local count, maximum = self:Counts()
    f.text:SetText(("Quests: %s / %d"):format(count or "--", maximum))
    if count and count >= maximum then f.text:SetTextColor(1, .3, .3)
    elseif count and maximum - count <= 5 then f.text:SetTextColor(1, .8, .2)
    else D.UI.Color(f.text, D.UI.C.text) end
    f:Show()
end

function Q:Attach()
    local map = WorldMapFrame
    if not map then return end
    if self.map ~= map then
        self.map = map
        map:HookScript("OnShow", function() Q:Attach(); Q:Update() end)
        map:HookScript("OnHide", function() if Q.badge then Q.badge:Hide() end end)
    end
    local panel = frame(QuestMapFrame) and QuestMapFrame or frame(map.QuestLog) and map.QuestLog
    if panel and self.panel ~= panel then
        self.panel = panel
        panel:HookScript("OnShow", function() Q:Update() end)
        panel:HookScript("OnHide", function() Q:Update() end)
    end
    self:Update()
end

for _, event in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "ADDON_LOADED" }) do
    D:On(event, function() Q:Attach() end)
end
for _, event in ipairs({ "QUEST_LOG_UPDATE", "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED" }) do
    D:On(event, function() Q:Update() end)
end

HP.Defer(55, "map-quest-counter", function()
    local C, UI = D.Config, D.UI
    local build = C.TABS[C.TAB.appearance].build
    C.TABS[C.TAB.appearance].build = function(canvas, width)
        local rows = build(canvas, width)
        rows[#rows + 1] = UI.CheckRow(canvas, C, {
            label = "Quest counter on the world map", default = true,
            desc = "Show accepted quests and available log capacity beside the map's quest list.",
            get = function() return D.db.ui.mapQuestCounter ~= false end,
            set = function(value) D.db.ui.mapQuestCounter = value; Q:Attach() end,
        }, width)
        return rows
    end
    local refresh = HP.Suite.Refresh
    function HP.Suite:Refresh(...)
        local result = refresh(self, ...)
        Q:Update()
        return result
    end
end)
