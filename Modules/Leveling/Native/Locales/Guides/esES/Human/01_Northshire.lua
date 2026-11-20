local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Human/01_Northshire.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "human-01-northshire", {
    ["Northshire (1-5)"] =
        "Villanorte (1-5)",
    ["Everything happens around Northshire Abbey: follow the arrow from NPC to NPC."] =
        "Todo pasa en torno a la Abadía de Villanorte: sigue la flecha de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
