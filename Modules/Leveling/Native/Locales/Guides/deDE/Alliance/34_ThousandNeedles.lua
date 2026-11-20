local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/34_ThousandNeedles.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-34-needles", {
    ["Thousand Needles (34)"] =
        "Tausend Nadeln (34)",
    ["Reach Thousand Needles through Theramore and the southern Barrens, or through Feralas; the goblin camp in the east is your base."] =
        "Nach Tausend Nadeln über Theramore und das südliche Brachland oder über Feralas; das Goblinlager im Osten ist deine Basis.",
})

end
_load('WTFDudeSuite',_WTF)
