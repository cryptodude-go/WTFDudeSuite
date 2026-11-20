local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Horde/27_Barrens.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "horde-27-barrens", {
    ["The Barrens and Stonetalon (27-28)"] =
        "Sertões e Torres de Pedra (27-28)",
    ["Zeppelin back to Orgrimmar for the higher quests of the Barrens and the Stonetalon Mountains."] =
        "Zepelim de volta a Orgrimmar para as missões mais altas dos Sertões e da Cordilheira das Torres de Pedra.",
    ["Sun Rock Retreat"] =
        "Retiro Rocha do Sol",
    ["Camp Taurajo"] =
        "Acampamento Taurajo",
})

end
_load('WTFDudeSuite',_WTF)
