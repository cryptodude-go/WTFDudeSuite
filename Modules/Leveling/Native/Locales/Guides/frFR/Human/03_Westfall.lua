local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Human/03_Westfall.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "human-03-westfall", {
    ["Westfall (12-16)"] =
        "Marche de l'Ouest (12-16)",
    ["Head west on the Goldshire road, then to Sentinel Hill in the middle of Westfall."] =
        "Direction l'ouest par la route de Comté-de-l'Or, puis la colline des Sentinelles au centre de la Marche.",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
    ["Sentinel Hill"] =
        "Colline des Sentinelles",
})

end
_load('WTFDudeSuite',_WTF)
