local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/OrcTroll/01_ValleyOfTrials.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "orc-01-valley", {
    ["Valley of Trials (1-5)"] =
        "Vallée des Épreuves (1-5)",
    ["Everything happens in the Valley of Trials: follow the arrow from NPC to NPC."] =
        "Tout se passe dans la vallée des Épreuves : suis la flèche de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
