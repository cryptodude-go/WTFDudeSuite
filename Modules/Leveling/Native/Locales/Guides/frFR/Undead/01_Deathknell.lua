local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Undead/01_Deathknell.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "undead-01-deathknell", {
    ["Deathknell (1-6)"] =
        "Le Glas (1-6)",
    ["Everything starts in Deathknell: follow the arrow from NPC to NPC."] =
        "Tout commence au Glas : suis la flèche de PNJ en PNJ.",
    ["Finish the level on nearby monsters before moving on."] =
        "Finis le niveau sur les monstres du coin avant la suite.",
})

end
_load('WTFDudeSuite',_WTF)
