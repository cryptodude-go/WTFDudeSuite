local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/DwarfGnome/01_Coldridge.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "dwarf-01-coldridge", {
    ["Coldridge Valley (1-5)"] =
        "Valle de Crestanevada (1-5)",
    ["Everything starts in Coldridge: follow the arrow from NPC to NPC."] =
        "Todo empieza en Crestanevada: sigue la flecha de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
