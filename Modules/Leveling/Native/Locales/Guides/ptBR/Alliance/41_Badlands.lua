local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/41_Badlands.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "Ermos (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "Os Ermos ficam a sudeste de Loch Modan.",
})

end
_load('WTFDudeSuite',_WTF)
