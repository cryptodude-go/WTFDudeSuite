local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Horde/20_Barrens.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "horde-20-barrens", {
    ["The Barrens and Stonetalon (19-20)"] =
        "Les Tarides et les Serres-Rocheuses (19-20)",
    ["The Crossroads, in the middle of the Barrens, is your base; the Stonetalon Mountains are west of the Barrens."] =
        "La Croisée, au centre des Tarides, est ta base ; les Serres-Rocheuses sont à l'ouest des Tarides.",
    ["Ratchet"] =
        "Cabestan",
    ["Sun Rock Retreat"] =
        "Retraite de Roche-Soleil",
})

end
_load('WTFDudeSuite',_WTF)
