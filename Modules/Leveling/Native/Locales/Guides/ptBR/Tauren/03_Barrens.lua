local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Tauren/03_Barrens.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "tauren-03-barrens", {
    ["The Barrens (12-19)"] =
        "Sertões (12-19)",
    ["Leave Mulgore by the road east into the Barrens, then north to the Crossroads: your base."] =
        "Saia de Mulgore pela estrada do leste rumo aos Sertões, depois siga ao norte até a Encruzilhada: sua base.",
    ["The Crossroads"] =
        "A Encruzilhada",
    ["Camp Taurajo"] =
        "Acampamento Taurajo",
})

end
_load('WTFDudeSuite',_WTF)
