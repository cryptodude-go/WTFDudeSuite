local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/OrcTroll/01_ValleyOfTrials.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "orc-01-valley", {
    ["Valley of Trials (1-5)"] =
        "Tal der Prüfungen (1-5)",
    ["Everything happens in the Valley of Trials: follow the arrow from NPC to NPC."] =
        "Alles spielt sich im Tal der Prüfungen ab: Folge dem Pfeil von NSC zu NSC.",
})

end
_load('WTFDudeSuite',_WTF)
