local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/42_SwampOfSorrows.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-42-swamp", {
    ["Swamp of Sorrows (41)"] =
        "Marais des Chagrins (41)",
    ["The Swamp of Sorrows is east of Deadwind Pass, south of Redridge."] =
        "Le Marais des Chagrins est à l'est du Défilé de Deuillevent, au sud des Carmines.",
})

end
_load('WTFDudeSuite',_WTF)
