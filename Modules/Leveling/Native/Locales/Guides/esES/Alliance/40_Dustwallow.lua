local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/40_Dustwallow.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-40-dustwallow", {
    ["Dustwallow Marsh (40)"] =
        "Marjal Revolcafango (40)",
    ["Boat from Menethil to Theramore, the Alliance base on the edge of the marsh."] =
        "Barco de Menethil a Theramore, la base de la Alianza al borde del marjal.",
    ["Theramore"] =
        "Theramore",
})

end
_load('WTFDudeSuite',_WTF)
