local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/54_Felwood.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-54-felwood", {
    ["Felwood (51-53)"] =
        "Teufelswald (51-53)",
    ["Felwood is north of Ashenvale: the Horde post is in the west of the zone."] =
        "Der Teufelswald liegt nördlich des Eschentals: Der Posten der Horde ist im Westen des Gebiets.",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
})

end
_load('WTFDudeSuite',_WTF)
