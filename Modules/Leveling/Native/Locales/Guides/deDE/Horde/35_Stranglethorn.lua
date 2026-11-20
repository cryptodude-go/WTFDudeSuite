local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/35_Stranglethorn.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-35-stv", {
    ["Stranglethorn Vale (34-36)"] =
        "Schlingendorntal (34-36)",
    ["Zeppelin from Orgrimmar to Grom'gol, the Horde camp in the north of Stranglethorn."] =
        "Zeppelin von Orgrimmar nach Grom'gol, dem Lager der Horde im Norden des Schlingendorntals.",
    ["Grom'gol"] =
        "Grom'gol",
    ["Booty Bay"] =
        "Beutebucht",
})

end
_load('WTFDudeSuite',_WTF)
