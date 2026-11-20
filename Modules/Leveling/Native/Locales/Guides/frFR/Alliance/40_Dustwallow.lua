local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/40_Dustwallow.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-40-dustwallow", {
    ["Dustwallow Marsh (40)"] =
        "Marécage d'Âprefange (40)",
    ["Boat from Menethil to Theramore, the Alliance base on the edge of the marsh."] =
        "Bateau de Menethil pour Theramore, la base de l'Alliance au bord du marécage.",
    ["Theramore"] =
        "Theramore",
})

end
_load('WTFDudeSuite',_WTF)
