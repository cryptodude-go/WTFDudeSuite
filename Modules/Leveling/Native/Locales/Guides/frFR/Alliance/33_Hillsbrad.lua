local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/33_Hillsbrad.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-33-hillsbrad", {
    ["Hillsbrad Foothills (32-34)"] =
        "Contreforts de Hautebrande (32-34)",
    ["From Menethil, the road north crosses Thandol Span to the Foothills: Southshore is your base."] =
        "Depuis Menethil, la route du nord passe par le gouffre de Thandol jusqu'aux Contreforts : Austrivage est ta base.",
    ["Southshore"] =
        "Austrivage",
    ["Finish the level on nearby monsters before moving on."] =
        "Finis le niveau sur les monstres du coin avant la suite.",
})

end
_load('WTFDudeSuite',_WTF)
