local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/42_SwampOfSorrows.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-42-swamp", {
    ["Swamp of Sorrows (41)"] =
        "Sümpfe des Elends (41)",
    ["The Swamp of Sorrows is east of Deadwind Pass, south of Redridge."] =
        "Die Sümpfe des Elends: östlich vom Gebirgspass der Totenwinde, südlich vom Rotkammgebirge.",
})

end
_load('WTFDudeSuite',_WTF)
