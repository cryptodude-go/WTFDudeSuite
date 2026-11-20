local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/DwarfGnome/01_Coldridge.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "dwarf-01-coldridge", {
    ["Coldridge Valley (1-5)"] =
        "Vale Cristálgida (1-5)",
    ["Everything starts in Coldridge: follow the arrow from NPC to NPC."] =
        "Tudo começa no Vale Cristálgida: siga a seta de NPC em NPC.",
})

end
_load('WTFDudeSuite',_WTF)
