local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/29_Ashenvale.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-29-ashenvale", {
    ["Ashenvale (27-31)"] =
        "Eschental (27-31)",
    ["Back to Astranaar for the last Ashenvale quests. Finish the level on nearby monsters before moving on."] =
        "Zurück nach Astranaar für die letzten Quests im Eschental. Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
    ["Auberdine"] =
        "Auberdine",
})

end
_load('WTFDudeSuite',_WTF)
