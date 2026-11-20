local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/OrcTroll/03_Barrens.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "orc-03-barrens", {
    ["The Barrens (11-19)"] =
        "Sertões (11-19)",
    ["Cross the bridge west of Razor Hill into the Barrens, then follow the road to the Crossroads: your base."] =
        "Cruze a ponte a oeste do Monte Navalha para entrar nos Sertões, depois siga a estrada até a Encruzilhada: sua base.",
    ["The Crossroads"] =
        "A Encruzilhada",
    ["Sun Rock Retreat"] =
        "Retiro Rocha do Sol",
    ["Orgrimmar"] =
        "Orgrimmar",
})

end
_load('WTFDudeSuite',_WTF)
