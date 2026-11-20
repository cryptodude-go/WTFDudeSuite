local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Undead/04_Barrens.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "undead-04-barrens", {
    ["The Barrens (15-20)"] =
        "Les Tarides (15-20)",
    ["Zeppelin from the towers outside Undercity to Orgrimmar, then the road west and south to the Crossroads: your base for the Barrens."] =
        "Zeppelin des tours près de Fossoyeuse pour Orgrimmar, puis la route de l'ouest et du sud jusqu'à la Croisée : c'est ta base pour les Tarides.",
    ["The Crossroads"] =
        "La Croisée",
})

end
_load('WTFDudeSuite',_WTF)
