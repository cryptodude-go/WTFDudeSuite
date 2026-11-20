local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/NightElf/03_Darkshore.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "nightelf-03-darkshore", {
    ["Darkshore (11-19)"] =
        "Dunkelküste (11-19)",
    ["Rut'theran (portal at the foot of Darnassus), then the boat to Auberdine: your base on Darkshore."] =
        "Rut'theran (Portal am Fuß von Darnassus), dann das Schiff nach Auberdine: deine Basis an der Dunkelküste.",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
    ["Auberdine"] =
        "Auberdine",
})

end
_load('WTFDudeSuite',_WTF)
