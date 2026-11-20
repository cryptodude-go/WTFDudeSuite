local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Horde/20_Barrens.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "horde-20-barrens", {
    ["The Barrens and Stonetalon (19-20)"] =
        "Sertões e Torres de Pedra (19-20)",
    ["The Crossroads, in the middle of the Barrens, is your base; the Stonetalon Mountains are west of the Barrens."] =
        "A Encruzilhada, no centro dos Sertões, é sua base; a Cordilheira das Torres de Pedra fica a oeste dos Sertões.",
    ["Ratchet"] =
        "Vila Catraca",
    ["Sun Rock Retreat"] =
        "Retiro Rocha do Sol",
})

end
_load('WTFDudeSuite',_WTF)
