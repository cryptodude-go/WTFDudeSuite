local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/55_BurningSteppes.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-55-burningsteppes", {
    ["Burning Steppes (54)"] =
        "Steppes ardentes (54)",
    ["The Burning Steppes are north of Redridge: the Alliance camp is in the east of the zone."] =
        "Les Steppes ardentes sont au nord des Carmines : le camp de l'Alliance est à l'est de la zone.",
})

end
_load('WTFDudeSuite',_WTF)
