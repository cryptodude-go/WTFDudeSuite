local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/42_SwampOfSorrows.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-42-swamp", {
    ["Swamp of Sorrows (41)"] =
        "Pântano das Mágoas (41)",
    ["The Swamp of Sorrows is east of Deadwind Pass, south of Redridge."] =
        "O Pântano das Mágoas fica a leste da Trilha do Vento Morto, ao sul de Cristarrubra.",
})

end
_load('WTFDudeSuite',_WTF)
