local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/23_Ashenvale.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-23-ashenvale", {
    ["Ashenvale (20-25)"] =
        "Eschental (20-25)",
    ["Ashenvale is north of the Barrens: Splintertree Post, in the east of the forest, is your base."] =
        "Das Eschental liegt nördlich des Brachlands: Der Splitterholzposten im Osten des Waldes ist deine Basis.",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
    ["Splintertree Post"] =
        "Splitterholzposten",
})

end
_load('WTFDudeSuite',_WTF)
