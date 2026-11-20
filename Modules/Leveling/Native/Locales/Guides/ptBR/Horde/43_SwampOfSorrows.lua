local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Horde/43_SwampOfSorrows.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "horde-43-swamp", {
    ["Swamp of Sorrows (42)"] =
        "Pântano das Mágoas (42)",
    ["The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base."] =
        "O Pântano das Mágoas fica a leste da Trilha do Vento Morto: Pedregal é sua base.",
    ["Stonard"] =
        "Pedregal",
})

end
_load('WTFDudeSuite',_WTF)
