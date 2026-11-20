local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/33_Desolace.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-33-desolace", {
    ["Desolace (32-34)"] =
        "Desolace (32-34)",
    ["Desolace is south of the Stonetalon Mountains: the Horde village is on the west coast. Finish the level on nearby monsters before moving on."] =
        "Desolace liegt südlich des Steinkrallengebirges: Das Dorf der Horde ist an der Westküste. Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
    ["Shadowprey Village"] =
        "Shadowprey Village",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
})

end
_load('WTFDudeSuite',_WTF)
