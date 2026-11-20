local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/27_Barrens.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-27-barrens", {
    ["The Barrens and Stonetalon (27-28)"] =
        "Brachland und Steinkrallengebirge (27-28)",
    ["Zeppelin back to Orgrimmar for the higher quests of the Barrens and the Stonetalon Mountains."] =
        "Zeppelin zurück nach Orgrimmar für die höheren Quests im Brachland und im Steinkrallengebirge.",
    ["Sun Rock Retreat"] =
        "Sonnenfels",
    ["Camp Taurajo"] =
        "Camp Taurajo",
})

end
_load('WTFDudeSuite',_WTF)
