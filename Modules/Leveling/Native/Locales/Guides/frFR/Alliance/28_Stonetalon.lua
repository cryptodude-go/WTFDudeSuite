local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/28_Stonetalon.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "Les Serres-Rocheuses (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "Les Serres-Rocheuses sont à l'ouest d'Orneval.",
    ["Stonetalon Peak"] =
        "Pic des Serres-Rocheuses",
})

end
_load('WTFDudeSuite',_WTF)
