local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/34_ThousandNeedles.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-34-needles", {
    ["Thousand Needles (34)"] =
        "Mil Agulhas (34)",
    ["Reach Thousand Needles through Theramore and the southern Barrens, or through Feralas; the goblin camp in the east is your base."] =
        "Chegue a Mil Agulhas por Theramore e o sul dos Sertões, ou por Feralas; o acampamento goblin a leste é sua base.",
})

end
_load('WTFDudeSuite',_WTF)
