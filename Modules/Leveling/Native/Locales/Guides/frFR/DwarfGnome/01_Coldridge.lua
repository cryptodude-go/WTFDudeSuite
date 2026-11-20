local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/DwarfGnome/01_Coldridge.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "dwarf-01-coldridge", {
    ["Coldridge Valley (1-5)"] =
        "Vallée de Frigrecif (1-5)",
    ["Everything starts in Coldridge: follow the arrow from NPC to NPC."] =
        "Tout commence à Frigrecif : suis la flèche de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
