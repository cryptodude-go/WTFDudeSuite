local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/OrcTroll/02_Durotar.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "orc-02-durotar", {
    ["Durotar (5-11)"] =
        "Durotar (5-11)",
    ["Leave the valley by the road east, then north to Razor Hill: your base for Durotar."] =
        "Sors de la vallée par la route de l'est, puis remonte au nord jusqu'à Tranchecolline : c'est ta base pour Durotar.",
    ["Razor Hill"] =
        "Tranchecolline",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
})

end
_load('WTFDudeSuite',_WTF)
