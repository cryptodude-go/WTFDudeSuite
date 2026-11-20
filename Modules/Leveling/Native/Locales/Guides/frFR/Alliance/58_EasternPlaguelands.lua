local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/58_EasternPlaguelands.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-58-epl", {
    ["Eastern Plaguelands (55-56)"] =
        "Maleterres de l'Est (55-56)",
    ["The Eastern Plaguelands continue the Western ones to the east: Light's Hope Chapel is in the east."] =
        "Les Maleterres de l'Est prolongent celles de l'Ouest vers l'est : la chapelle de l'Espoir de Lumière est à l'est.",
    ["Light's Hope Chapel"] =
        "Chapelle de l'Espoir de Lumière",
    ["Finish the level on nearby monsters before moving on."] =
        "Finis le niveau sur les monstres du coin avant la suite.",
})

end
_load('WTFDudeSuite',_WTF)
