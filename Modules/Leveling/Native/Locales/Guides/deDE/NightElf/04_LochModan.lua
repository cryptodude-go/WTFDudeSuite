local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/NightElf/04_LochModan.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "nightelf-04-lochmodan", {
    ["Loch Modan (19-21)"] =
        "Loch Modan (19-21)",
    ["Boat from Auberdine to Menethil Harbor, then the road east through the Wetlands to Loch Modan: Thelsamar is your base."] =
        "Schiff von Auberdine zum Hafen von Menethil, dann die Straße nach Osten durch das Sumpfland bis Loch Modan: Thelsamar ist deine Basis.",
    ["Thelsamar"] =
        "Thelsamar",
})

end
_load('WTFDudeSuite',_WTF)
