local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/OrcTroll/01_ValleyOfTrials.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "orc-01-valley", {
    ["Valley of Trials (1-5)"] =
        "Valle de los Retos (1-5)",
    ["Everything happens in the Valley of Trials: follow the arrow from NPC to NPC."] =
        "Todo pasa en el Valle de los Retos: sigue la flecha de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
