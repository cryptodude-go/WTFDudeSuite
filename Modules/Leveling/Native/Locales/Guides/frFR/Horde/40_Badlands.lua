local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Horde/40_Badlands.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "horde-40-badlands", {
    ["Badlands (38)"] =
        "Terres ingrates (38)",
    ["Fly from Hammerfall to Kargath, in the west of the Badlands."] =
        "Vol de Trépas-d'Orgrim pour Kargath, à l'ouest des Terres ingrates.",
    ["Kargath"] =
        "Kargath",
})

end
_load('WTFDudeSuite',_WTF)
