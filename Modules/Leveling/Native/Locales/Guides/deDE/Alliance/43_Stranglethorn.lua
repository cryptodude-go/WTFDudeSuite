local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/43_Stranglethorn.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-43-stv", {
    ["Stranglethorn Vale (41)"] =
        "Schlingendorntal (41)",
    ["Back to Stranglethorn for the end of its quests, from Booty Bay."] =
        "Zurück ins Schlingendorntal für seine letzten Quests, ab Beutebucht.",
    ["Booty Bay"] =
        "Beutebucht",
})

end
_load('WTFDudeSuite',_WTF)
