local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/43_SwampOfSorrows.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-43-swamp", {
    ["Swamp of Sorrows (42)"] =
        "Sümpfe des Elends (42)",
    ["The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base."] =
        "Sümpfe des Elends, östlich vom Gebirgspass der Totenwinde: Steinard ist deine Basis.",
    ["Stonard"] =
        "Steinard",
})

end
_load('WTFDudeSuite',_WTF)
