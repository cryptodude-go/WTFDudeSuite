local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/40_Dustwallow.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-40-dustwallow", {
    ["Dustwallow Marsh (40)"] =
        "Pântano Vadeoso (40)",
    ["Boat from Menethil to Theramore, the Alliance base on the edge of the marsh."] =
        "Barco de Menethil para Theramore, a base da Aliança à beira do pântano.",
    ["Theramore"] =
        "Theramore",
})

end
_load('WTFDudeSuite',_WTF)
