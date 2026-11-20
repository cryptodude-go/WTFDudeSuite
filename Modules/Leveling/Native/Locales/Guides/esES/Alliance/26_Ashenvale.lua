local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/26_Ashenvale.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-26-ashenvale", {
    ["Ashenvale (26-27)"] =
        "Vallefresno (26-27)",
    ["Boat from Menethil to Auberdine, then the road south to Ashenvale: Astranaar is your base."] =
        "Barco de Menethil a Auberdine y luego el camino al sur hasta Vallefresno: Astranaar es tu base.",
    ["Astranaar"] =
        "Astranaar",
})

end
_load('WTFDudeSuite',_WTF)
