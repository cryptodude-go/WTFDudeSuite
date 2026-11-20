local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/28_Stonetalon.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "Sierra Espolón (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "La Sierra Espolón está al oeste de Vallefresno.",
    ["Stonetalon Peak"] =
        "Cima del Espolón",
})

end
_load('WTFDudeSuite',_WTF)
