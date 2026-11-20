local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/47_Feralas.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-47-feralas", {
    ["Feralas (47-48)"] =
        "Feralas (47-48)",
    ["The Alliance stronghold of Feralas is on an island west of the zone."] =
        "O bastião da Aliança em Feralas fica numa ilha a oeste da zona.",
    ["Feathermoon Stronghold"] =
        "Domínio de Plumaluna",
    ["If the starting item dropped: use it from your bags."] =
        "Se o item inicial caiu: use-o direto das bolsas.",
})

end
_load('WTFDudeSuite',_WTF)
