local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/NightElf/02_Teldrassil.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "nightelf-02-dolanaar", {
    ["Teldrassil (6-11)"] =
        "Teldrassil (6-11)",
    ["Dolanaar is your base for Teldrassil: inn, class trainers and most quests."] =
        "Dolanaar ist deine Basis für Teldrassil: Gasthaus, Klassenlehrer und die meisten Quests.",
    ["Dolanaar"] =
        "Dolanaar",
})

end
_load('WTFDudeSuite',_WTF)
