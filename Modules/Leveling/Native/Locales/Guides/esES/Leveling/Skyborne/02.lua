local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Leveling/Skyborne/02.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "leveling-s02-skyborne-horde", {
    ["Skyborne start (1-13)"] =
        "Inicio skyborne (1-13)",
    ["Everything starts on Zephras Isle: follow the arrow from NPC to NPC."] =
        "Todo empieza en la isla de Zephras: sigue la flecha de PNJ en PNJ.",
    ["Coriella Calmbreeze"] =
        "Coriella Calmbreeze",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
    ["Donaal Downbreeze"] =
        "Donaal Downbreeze",
    ["If the starting item dropped: use it from your bags."] =
        "Si tienes el objeto que inicia la misión: úsalo desde tus bolsas.",
})

end
_load('WTFDudeSuite',_WTF)
