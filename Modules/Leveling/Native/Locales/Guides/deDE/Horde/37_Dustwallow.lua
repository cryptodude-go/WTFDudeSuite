local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/37_Dustwallow.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-37-dustwallow", {
    ["Dustwallow and Thousand Needles (36-37)"] =
        "Düstermarschen und Tausend Nadeln (36-37)",
    ["Zeppelin back to Orgrimmar. Dustwallow Marsh is east of the southern Barrens, with Brackenwall Village in the north of the marsh; the Shimmering Flats are in the east of Thousand Needles."] =
        "Zeppelin zurück nach Orgrimmar. Die Düstermarschen liegen östlich des südlichen Brachlands, mit Brackenwall Village im Norden der Marschen; die Schimmernde Ebene ist im Osten von Tausend Nadeln.",
})

end
_load('WTFDudeSuite',_WTF)
