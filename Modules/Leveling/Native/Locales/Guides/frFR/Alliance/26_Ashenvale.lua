local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/26_Ashenvale.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-26-ashenvale", {
    ["Ashenvale (26-27)"] =
        "Orneval (26-27)",
    ["Boat from Menethil to Auberdine, then the road south to Ashenvale: Astranaar is your base."] =
        "Bateau de Menethil pour Auberdine, puis la route du sud jusqu'à Orneval : Astranaar est ta base.",
    ["Astranaar"] =
        "Astranaar",
})

end
_load('WTFDudeSuite',_WTF)
