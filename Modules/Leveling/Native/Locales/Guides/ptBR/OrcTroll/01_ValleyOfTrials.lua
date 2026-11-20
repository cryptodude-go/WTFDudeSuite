local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/OrcTroll/01_ValleyOfTrials.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "orc-01-valley", {
    ["Valley of Trials (1-5)"] =
        "Vale das Provações (1-5)",
    ["Everything happens in the Valley of Trials: follow the arrow from NPC to NPC."] =
        "Tudo acontece no Vale das Provações: siga a seta de NPC em NPC.",
})

end
_load('WTFDudeSuite',_WTF)
