local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/NightElf/02_Teldrassil.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "nightelf-02-dolanaar", {
    ["Teldrassil (6-11)"] =
        "Teldrassil (6-11)",
    ["Dolanaar is your base for Teldrassil: inn, class trainers and most quests."] =
        "Dolanaar es tu base en Teldrassil: posada, instructores de clase y casi todas las misiones.",
    ["Dolanaar"] =
        "Dolanaar",
})

end
_load('WTFDudeSuite',_WTF)
