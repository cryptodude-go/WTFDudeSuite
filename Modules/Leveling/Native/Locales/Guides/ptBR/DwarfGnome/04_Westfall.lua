local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/DwarfGnome/04_Westfall.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "dwarf-04-westfall", {
    ["Westfall (14-18)"] =
        "Cerro Oeste (14-18)",
    ["Deeprun Tram from Ironforge to Stormwind, then the road west through Goldshire to Sentinel Hill."] =
        "Metrô Correfundo de Altaforja até Ventobravo, depois a estrada para oeste por Vila d'Ouro até o Morro da Sentinela.",
    ["If the starting item dropped: use it from your bags."] =
        "Se o item inicial caiu: use-o direto das bolsas.",
    ["Sentinel Hill"] =
        "Morro da Sentinela",
})

end
_load('WTFDudeSuite',_WTF)
