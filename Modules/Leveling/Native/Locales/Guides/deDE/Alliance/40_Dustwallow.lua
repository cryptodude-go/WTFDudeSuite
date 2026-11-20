local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/40_Dustwallow.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-40-dustwallow", {
    ["Dustwallow Marsh (40)"] =
        "Düstermarschen (40)",
    ["Boat from Menethil to Theramore, the Alliance base on the edge of the marsh."] =
        "Schiff von Menethil nach Theramore, der Basis der Allianz am Rand der Marschen.",
    ["Theramore"] =
        "Theramore",
})

end
_load('WTFDudeSuite',_WTF)
