local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/28_Stonetalon.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "Cordilheira das Torres de Pedra (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "A Cordilheira das Torres de Pedra fica a oeste do Vale Gris.",
    ["Stonetalon Peak"] =
        "Morro das Torres de Pedra",
})

end
_load('WTFDudeSuite',_WTF)
