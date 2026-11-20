local _, HP = ...
local D = HP.Native
local U = { sent = {}, repository = "https://github.com/cryptodude-go/WTFDudeSuite" }
D.Updates = U
local PREFIX = "WTFDudeVersion"
local channels = { PARTY = true, RAID = true, INSTANCE_CHAT = true, GUILD = true }

function U.Parse(value)
    if not HP.Public(value) or type(value) ~= "string" or #value > 32 then return end
    value = value:gsub("^v", "")
    if not value:match("^%d+%.%d+[%.%d]*$") or value:match("%.%.") or value:sub(-1) == "." then return end
    local parts = {}
    for part in value:gmatch("%d+") do
        local n = tonumber(part)
        if n > 99999 then return end
        parts[#parts + 1] = n
    end
    if #parts > 4 then return end
    return parts, value
end

function U.Newer(a, b)
    local left, right = U.Parse(a), U.Parse(b)
    if not left or not right then return false end
    for i = 1, math.max(#left, #right) do
        local x, y = left[i] or 0, right[i] or 0
        if x ~= y then return x > y end
    end
    return false
end

function U:Version()
    local _, version = self.Parse(D.version)
    if version then return version end
    return HP.Suite.version
end

function U:Enabled()
    return D.db and D.db.ui.updateNotifications ~= false and HP.Suite:On("suite")
end

function U:Consider(version, source)
    local _, clean = self.Parse(version)
    if not clean or not self.Newer(clean, self:Version()) then return end
    if not self.available or self.Newer(clean, self.available.version)
        or clean == self.available.version and source == "github" then
        self.available = { version = clean, source = source }
    end
    if not self:Enabled() or not self.Newer(self.available.version, D.db.ui.updateNoticeSeen or "0.0") then return end
    if self.pending then return end
    self.pending = true
    C_Timer.After(2, function() U:Notify() end)
end

function U:Notify()
    if not self.pending or not self.available or not self:Enabled() then self.pending = nil; return end
    if HP.Call(InCombatLockdown) then return end
    self.pending = nil
    if not self.Newer(self.available.version, D.db.ui.updateNoticeSeen or "0.0") then return end
    D.db.ui.updateNoticeSeen = self.available.version
    self:Open()
end

local function button(parent, text, x, run)
    local UI = D.UI
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(150, 28)
    b:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", x, 14)
    b.bg = UI.Shape(b, "row", UI.C.control, "BACKGROUND"):Place(b)
    b.label = UI.Text(b, "medium", 12, UI.C.text)
    b.label:SetPoint("CENTER")
    b.label:SetText(text)
    b:SetScript("OnClick", run)
    return b
end

function U:Open()
    local UI = D.UI
    local f = self.frame
    if not f then
        f = CreateFrame("Frame", "WTFDudeSuiteUpdateWindow", UIParent)
        self.frame = f
        f:SetSize(500, 260)
        f:SetFrameStrata("DIALOG")
        UI.Dialog(f, 0, 80)
        f.look = UI.Window(f, "dialog")
        UI.DialogBars(f, 38)
        f.title = UI.Text(f, "semibold", 14, UI.C.text)
        f.title:SetPoint("TOPLEFT", 18, -13)
        f.body = UI.Text(f, "regular", 12, UI.C.text)
        f.body:SetPoint("TOPLEFT", 18, -54)
        f.body:SetWidth(464)
        f.body:SetJustifyH("LEFT")
        f.link = CreateFrame("EditBox", nil, f)
        f.link:SetAutoFocus(false)
        f.link:SetFontObject(UI.Font("regular", 11))
        f.link:SetSize(464, 24)
        f.link:SetPoint("BOTTOMLEFT", 18, 58)
        f.link:SetText(self.repository)
        f.link:SetScript("OnEscapePressed", function() f:Hide() end)
        f.link:SetScript("OnTextChanged", function(edit, typed)
            if typed then edit:SetText(U.repository); edit:HighlightText() end
        end)
        button(f, "Copy GitHub link", 18, function()
            f.link:SetFocus(); f.link:HighlightText()
        end)
        button(f, "Close", 332, function() f:Hide() end)
        f:SetScript("OnHide", function() f.link:ClearFocus() end)
        UISpecialFrames = UISpecialFrames or {}
        UISpecialFrames[#UISpecialFrames + 1] = "WTFDudeSuiteUpdateWindow"
    end
    f.title:SetText("WTF! DUDE SUITE · " .. (self.available and "Update available" or "Version information"))
    local message = "Installed version: v" .. self:Version()
    if self.available then
        message = message .. "\nNewer version: v" .. self.available.version
        message = message .. (self.available.source == "github"
            and "\nFound by the GitHub checker."
            or "\nReported by another suite user. Check GitHub for the release.")
    else
        message = message .. "\nNo newer version has been reported."
    end
    f.body:SetText(message .. "\n\nSelect the link, press Ctrl+C, and open it in your browser.")
    f.link:SetText(self.repository)
    f:Show()
end

function U:CheckCached()
    local info = HP.releaseInfo
    if type(info) == "table" and info.repository == "cryptodude-go/WTFDudeSuite" then
        self:Consider(info.version, "github")
    end
end

function U:Send(channel)
    if not self.registered or not self:Enabled() or not channels[channel] then return end
    local now = HP.Call(GetTime) or 0
    if self.sent[channel] and now - self.sent[channel] < 30 then return end
    self.sent[channel] = now
    HP.Call(C_ChatInfo and C_ChatInfo.SendAddonMessage or SendAddonMessage,
        PREFIX, "V|" .. self:Version(), channel)
end

function U:Announce()
    if not self:Enabled() then return end
    if HP.Call(IsInGuild) then self:Send("GUILD") end
    if HP.Call(IsInGroup, LE_PARTY_CATEGORY_INSTANCE or 2) then self:Send("INSTANCE_CHAT")
    elseif HP.Call(IsInRaid) then self:Send("RAID")
    elseif HP.Call(IsInGroup) then self:Send("PARTY") end
end

function U:Schedule()
    if self.queued then return end
    self.queued = true
    C_Timer.After(5, function() U.queued = nil; U:Announce() end)
end

D:On("PLAYER_LOGIN", function()
    local result = HP.Call(C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix, PREFIX)
    U.registered = result == true or result == 0 or result == 1
    U:CheckCached()
    U:Schedule()
end)
D:On("GROUP_ROSTER_UPDATE", function() U:Schedule() end)
D:On("PLAYER_GUILD_UPDATE", function() U:Schedule() end)
D:On("PLAYER_REGEN_ENABLED", function() U:Notify() end)
D:On("CHAT_MSG_ADDON", function(_, prefix, message, channel)
    if not U:Enabled() or not HP.Public(prefix) or prefix ~= PREFIX
        or not HP.Public(channel) or not channels[channel]
        or not HP.Public(message) or type(message) ~= "string" or #message > 40 then return end
    local version = message:match("^V|(.+)$")
    if not U.Parse(version) then return end
    U:Consider(version, "peer")
    if U.Newer(U:Version(), version) then U:Send(channel) end
end)

HP.Defer(50, "version-notifications", function()
    local C, UI = D.Config, D.UI
    local build = C.TABS[C.TAB.appearance].build
    C.TABS[C.TAB.appearance].build = function(canvas, width)
        local rows = build(canvas, width)
        rows[#rows + 1] = UI.CheckRow(canvas, C, {
            label = "New version notifications", default = true,
            desc = "Compare versions with suite users in your group or guild and read optional GitHub-check results at login.",
            get = function() return D.db.ui.updateNotifications ~= false end,
            set = function(value)
                D.db.ui.updateNotifications = value
                if value then U:CheckCached(); U:Schedule()
                elseif U.frame then U.frame:Hide() end
            end,
        }, width)
        rows[#rows + 1] = UI.ButtonRow(canvas, C, {
            label = "Version information & GitHub", button = "Open",
            run = function() U:Open() end,
        }, width)
        return rows
    end
    local command = SlashCmdList.WTFDUDESUITE
    SlashCmdList.WTFDUDESUITE = function(input)
        local key = (input or ""):lower():match("^%s*(.-)%s*$")
        if key == "updates" or key == "version" then U:Open(); return end
        return command(input)
    end
end)
