local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/40_Badlands.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-40-badlands", {
    ["Badlands (38)"] =
        "Ödland (38)",
    ["Fly from Hammerfall to Kargath, in the west of the Badlands."] =
        "Flieg von Hammerfall nach Kargath im Westen des Ödlands.",
    ["Kargath"] =
        "Kargath",
})

end
_load('WTFDudeSuite',_WTF)
