local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/NightElf/02_Teldrassil.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "nightelf-02-dolanaar", {
    ["Teldrassil (6-11)"] =
        "Teldrassil (6-11)",
    ["Dolanaar is your base for Teldrassil: inn, class trainers and most quests."] =
        "Dolanaar est ta base pour Teldrassil : auberge, maîtres de classe et la plupart des quêtes.",
    ["Dolanaar"] =
        "Dolanaar",
})

end
_load('WTFDudeSuite',_WTF)
