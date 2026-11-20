local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/NightElf/03_Darkshore.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "nightelf-03-darkshore", {
    ["Darkshore (11-19)"] =
        "Sombrivage (11-19)",
    ["Rut'theran (portal at the foot of Darnassus), then the boat to Auberdine: your base on Darkshore."] =
        "Rut'theran (portail au pied de Darnassus), puis le bateau pour Auberdine : c'est ta base sur Sombrivage.",
    ["Finish the level on nearby monsters before moving on."] =
        "Finis le niveau sur les monstres du coin avant la suite.",
    ["Auberdine"] =
        "Auberdine",
})

end
_load('WTFDudeSuite',_WTF)
