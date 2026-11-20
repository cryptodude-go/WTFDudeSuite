local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/DwarfGnome/04_Westfall.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "dwarf-04-westfall", {
    ["Westfall (14-18)"] =
        "Marche de l'Ouest (14-18)",
    ["Deeprun Tram from Ironforge to Stormwind, then the road west through Goldshire to Sentinel Hill."] =
        "Tram des profondeurs de Forgefer à Hurlevent, puis la route de l'ouest par Comté-de-l'Or jusqu'à la colline des Sentinelles.",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
    ["Sentinel Hill"] =
        "Colline des Sentinelles",
})

end
_load('WTFDudeSuite',_WTF)
