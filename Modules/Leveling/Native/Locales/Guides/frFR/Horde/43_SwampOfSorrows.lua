local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Horde/43_SwampOfSorrows.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "horde-43-swamp", {
    ["Swamp of Sorrows (42)"] =
        "Marais des Chagrins (42)",
    ["The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base."] =
        "Le Marais des Chagrins est à l'est du défilé de Deuillevent : Pierrêche est ta base.",
    ["Stonard"] =
        "Pierrêche",
})

end
_load('WTFDudeSuite',_WTF)
