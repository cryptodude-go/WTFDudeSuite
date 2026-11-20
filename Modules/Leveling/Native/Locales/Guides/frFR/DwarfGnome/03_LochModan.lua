local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/DwarfGnome/03_LochModan.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "dwarf-03-lochmodan", {
    ["Loch Modan (11-14)"] =
        "Loch Modan (11-14)",
    ["Take the road east through the South Gate tunnel to Thelsamar."] =
        "Prends la route de l'est par le tunnel de la porte Sud jusqu'à Thelsamar.",
    ["Thelsamar"] =
        "Thelsamar",
    ["Finish the level on nearby monsters before moving on."] =
        "Finis le niveau sur les monstres du coin avant la suite.",
})

end
_load('WTFDudeSuite',_WTF)
