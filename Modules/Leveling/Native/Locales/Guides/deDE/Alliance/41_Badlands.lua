local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/41_Badlands.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "Ödland (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "Das Ödland liegt südöstlich von Loch Modan.",
})

end
_load('WTFDudeSuite',_WTF)
