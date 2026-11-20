local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/41_Badlands.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "Terres ingrates (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "Les Terres ingrates sont au sud-est de Loch Modan.",
})

end
_load('WTFDudeSuite',_WTF)
