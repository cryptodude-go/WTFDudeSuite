local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/26_Ashenvale.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-26-ashenvale", {
    ["Ashenvale (26-27)"] =
        "Vale Gris (26-27)",
    ["Boat from Menethil to Auberdine, then the road south to Ashenvale: Astranaar is your base."] =
        "Barco de Menethil para Auberdine, depois a estrada para o sul até o Vale Gris: Astranaar é sua base.",
    ["Astranaar"] =
        "Astranaar",
})

end
_load('WTFDudeSuite',_WTF)
