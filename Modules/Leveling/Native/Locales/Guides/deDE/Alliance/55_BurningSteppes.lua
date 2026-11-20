local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/55_BurningSteppes.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-55-burningsteppes", {
    ["Burning Steppes (54)"] =
        "Brennende Steppe (54)",
    ["The Burning Steppes are north of Redridge: the Alliance camp is in the east of the zone."] =
        "Die Brennende Steppe liegt nördlich des Rotkammgebirges: Das Lager der Allianz ist im Osten des Gebiets.",
})

end
_load('WTFDudeSuite',_WTF)
