local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Horde/33_Desolace.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "horde-33-desolace", {
    ["Desolace (32-34)"] =
        "Desolação (32-34)",
    ["Desolace is south of the Stonetalon Mountains: the Horde village is on the west coast. Finish the level on nearby monsters before moving on."] =
        "Desolação fica ao sul da Cordilheira das Torres de Pedra: a aldeia da Horda está na costa oeste. Termine o nível nos monstros próximos antes de seguir.",
    ["Shadowprey Village"] =
        "Aldeia Pescassombra",
    ["Finish the level on nearby monsters before moving on."] =
        "Termine o nível nos monstros próximos antes de seguir.",
})

end
_load('WTFDudeSuite',_WTF)
