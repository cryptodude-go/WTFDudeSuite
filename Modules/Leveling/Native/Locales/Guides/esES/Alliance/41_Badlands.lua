local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/41_Badlands.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "Tierras Inhóspitas (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "Las Tierras Inhóspitas están al sureste de Loch Modan.",
})

end
_load('WTFDudeSuite',_WTF)
