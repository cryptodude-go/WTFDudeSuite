local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Tauren/01_CampNarache.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "tauren-01-narache", {
    ["Camp Narache (1-5)"] =
        "Aldeia Narache (1-5)",
    ["Everything starts at Camp Narache: follow the arrow from NPC to NPC."] =
        "Tudo começa na Aldeia Narache: siga a seta de NPC em NPC.",
})

end
_load('WTFDudeSuite',_WTF)
