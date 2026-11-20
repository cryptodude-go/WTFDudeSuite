local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/43_SwampOfSorrows.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-43-swamp", {
    ["Swamp of Sorrows (42)"] =
        "Pantano de las Penas (42)",
    ["The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base."] =
        "El Pantano de las Penas está al este del Paso de la Muerte: Rocal es tu base.",
    ["Stonard"] =
        "Rocal",
})

end
_load('WTFDudeSuite',_WTF)
