local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Human/02_Elwynn.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "human-02-elwynn", {
    ["Elwynn Forest (5-12)"] =
        "Forêt d'Elwynn (5-12)",
    ["Goldshire is your base for the whole forest: inn, class trainers and quests."] =
        "Comté-de-l'Or est ta base pour toute la forêt : auberge, maîtres de classe et quêtes.",
    ["Goldshire"] =
        "Comté-de-l'Or",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
    ["Finish the level on nearby monsters before moving on."] =
        "Finis le niveau sur les monstres du coin avant la suite.",
})

end
_load('WTFDudeSuite',_WTF)
