local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Horde/40_Badlands.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "horde-40-badlands", {
    ["Badlands (38)"] =
        "Ermos (38)",
    ["Fly from Hammerfall to Kargath, in the west of the Badlands."] =
        "Voe de Ruína do Martelo até Karrath, no oeste dos Ermos.",
    ["Kargath"] =
        "Karrath",
})

end
_load('WTFDudeSuite',_WTF)
