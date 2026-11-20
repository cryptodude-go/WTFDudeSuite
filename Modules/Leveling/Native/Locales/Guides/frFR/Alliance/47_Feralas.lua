local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/47_Feralas.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-47-feralas", {
    ["Feralas (47-48)"] =
        "Féralas (47-48)",
    ["The Alliance stronghold of Feralas is on an island west of the zone."] =
        "Le bastion de l'Alliance de Féralas est sur une île à l'ouest de la zone.",
    ["Feathermoon Stronghold"] =
        "Bastion de Pennelune",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
})

end
_load('WTFDudeSuite',_WTF)
