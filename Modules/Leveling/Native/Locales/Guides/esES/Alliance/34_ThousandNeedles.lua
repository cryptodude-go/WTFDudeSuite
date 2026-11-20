local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/34_ThousandNeedles.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-34-needles", {
    ["Thousand Needles (34)"] =
        "Las Mil Agujas (34)",
    ["Reach Thousand Needles through Theramore and the southern Barrens, or through Feralas; the goblin camp in the east is your base."] =
        "Llega a Las Mil Agujas por Theramore y el sur de Los Baldíos, o por Feralas; el campamento goblin del este es tu base.",
})

end
_load('WTFDudeSuite',_WTF)
