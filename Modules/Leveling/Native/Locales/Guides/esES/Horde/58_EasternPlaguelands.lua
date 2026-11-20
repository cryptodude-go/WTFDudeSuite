local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/58_EasternPlaguelands.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-58-epl", {
    ["Eastern Plaguelands (56)"] =
        "Tierras de la Peste del Este (56)",
    ["The Eastern Plaguelands continue the Western ones to the east: Light's Hope Chapel is in the east."] =
        "Las Tierras de la Peste del Este siguen a las del Oeste: la Capilla de la Esperanza de la Luz está al este.",
    ["Light's Hope Chapel"] =
        "Capilla de la Esperanza de la Luz",
})

end
_load('WTFDudeSuite',_WTF)
