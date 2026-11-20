local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/42_SwampOfSorrows.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-42-swamp", {
    ["Swamp of Sorrows (41)"] =
        "Pantano de las Penas (41)",
    ["The Swamp of Sorrows is east of Deadwind Pass, south of Redridge."] =
        "El Pantano de las Penas está al este del Paso de la Muerte, al sur de Crestagrana.",
})

end
_load('WTFDudeSuite',_WTF)
