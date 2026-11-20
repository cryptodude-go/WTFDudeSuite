local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Undead/04_Barrens.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "undead-04-barrens", {
    ["The Barrens (15-20)"] =
        "Sertões (15-20)",
    ["Zeppelin from the towers outside Undercity to Orgrimmar, then the road west and south to the Crossroads: your base for the Barrens."] =
        "Zepelim das torres perto da Cidade Baixa até Orgrimmar, depois a estrada para oeste e sul até a Encruzilhada: sua base nos Sertões.",
    ["The Crossroads"] =
        "A Encruzilhada",
})

end
_load('WTFDudeSuite',_WTF)
