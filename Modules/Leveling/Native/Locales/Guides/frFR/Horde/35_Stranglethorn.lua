local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Horde/35_Stranglethorn.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "horde-35-stv", {
    ["Stranglethorn Vale (34-36)"] =
        "Strangleronce (34-36)",
    ["Zeppelin from Orgrimmar to Grom'gol, the Horde camp in the north of Stranglethorn."] =
        "Zeppelin d'Orgrimmar pour Grom'gol, le camp de la Horde au nord de Strangleronce.",
    ["Grom'gol"] =
        "Grom'gol",
    ["Booty Bay"] =
        "Baie-du-Butin",
})

end
_load('WTFDudeSuite',_WTF)
