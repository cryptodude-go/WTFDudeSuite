local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Horde/58_EasternPlaguelands.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "horde-58-epl", {
    ["Eastern Plaguelands (56)"] =
        "Maleterres de l'Est (56)",
    ["The Eastern Plaguelands continue the Western ones to the east: Light's Hope Chapel is in the east."] =
        "Les Maleterres de l'Est prolongent celles de l'Ouest vers l'est : la chapelle de l'Espoir de Lumière est à l'est.",
    ["Light's Hope Chapel"] =
        "Chapelle de l'Espoir de Lumière",
})

end
_load('WTFDudeSuite',_WTF)
