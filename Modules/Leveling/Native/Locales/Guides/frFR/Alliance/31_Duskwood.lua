local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/31_Duskwood.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-31-duskwood", {
    ["Duskwood (31-32)"] =
        "Bois de la Pénombre (31-32)",
    ["Back to Duskwood for the end of its quests: Darkshire is still your base."] =
        "Retour au Bois de la Pénombre pour la fin de ses quêtes : Sombre-Comté est toujours ta base.",
    ["Darkshire"] =
        "Sombre-Comté",
})

end
_load('WTFDudeSuite',_WTF)
