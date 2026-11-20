local HP = _G.WTFDudeSuiteRuntime
local D = HP.Native
local K = { recent = {} }
HP.KillingBlow = K
local sound = "Interface\\AddOns\\WTFDudeSuite\\Modules\\Community\\Media\\Killshot.wav"

function K:Play()
    HP.Call(PlaySoundFile, sound, "Master")
end

function K:OnKill(killer, victim)
    if not HP.db or HP.db.pvpKillSound == false or not HP.Suite:On("community") then return end
    if not HP.Public(killer) or not HP.Public(victim) or type(killer) ~= "string"
        or type(victim) ~= "string" or not victim:match("^Player%-") then return end
    local player = HP.Call(UnitGUID, "player")
    local pet = HP.Call(UnitGUID, "pet")
    if killer ~= player and killer ~= pet then return end
    local now = HP.Call(GetTime) or 0
    if self.recent[victim] and now - self.recent[victim] < 5 then return end
    for guid, at in pairs(self.recent) do
        if now - at >= 5 then self.recent[guid] = nil end
    end
    self.recent[victim] = now
    self:Play()
end

D:On("PARTY_KILL", function(_, killer, victim) K:OnKill(killer, victim) end)

HP.Defer(30, "pvp-killing-blow", function()
    local C, UI = D.Config, D.UI
    local build = C.TABS[C.TAB.community].build
    C.TABS[C.TAB.community].build = function(canvas, width)
        local rows = build(canvas, width)
        rows[#rows + 1] = UI.HeaderRow(canvas, "PvP killing blow", width)
        rows[#rows + 1] = UI.CheckRow(canvas, C, {
            label = "Pistol sound on my PvP killing blow", default = true,
            desc = "One shot for a player kill credited to you or your pet. Requires a readable kill event from the game.",
            get = function() return HP.db.pvpKillSound ~= false end,
            set = function(value) HP.db.pvpKillSound = value end,
        }, width)
        rows[#rows + 1] = UI.ButtonRow(canvas, C, {
            label = "Pistol sound preview", button = "Play",
            run = function() K:Play() end,
        }, width)
        return rows
    end
end)
