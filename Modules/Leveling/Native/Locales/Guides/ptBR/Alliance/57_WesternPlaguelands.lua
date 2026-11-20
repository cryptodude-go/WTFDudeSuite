local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/57_WesternPlaguelands.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-57-wpl", {
    ["Western Plaguelands (54-55)"] =
        "Terras Pestilentas Ocidentais (54-55)",
    ["The Western Plaguelands are north of Hillsbrad Foothills: the Alliance camp is in the south of the zone."] =
        "As Terras Pestilentas Ocidentais ficam ao norte do Contraforte de Eira dos Montes: o acampamento da Aliança está no sul da zona.",
    ["Ironforge"] =
        "Altaforja",
    ["Finish the level on nearby monsters before moving on."] =
        "Termine o nível nos monstros próximos antes de seguir.",
})

end
_load('WTFDudeSuite',_WTF)
