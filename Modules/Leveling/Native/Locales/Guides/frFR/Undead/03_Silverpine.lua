local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Undead/03_Silverpine.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "undead-03-silverpine", {
    ["Silverpine Forest (13-15)"] =
        "Forêt des Pins-Argentés (13-15)",
    ["From Brill, take the road west then south over the bridge into Silverpine Forest: the Sepulcher is your base."] =
        "Depuis Brill, prends la route de l'ouest puis du sud, par le pont, jusqu'à la forêt des Pins-Argentés : le Sépulcre est ta base.",
    ["The Sepulcher"] =
        "Le Sépulcre",
})

end
_load('WTFDudeSuite',_WTF)
