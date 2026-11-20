local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/41_Badlands.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "荒芜之地 (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "荒芜之地在洛克莫丹东南。",
})

end
_load('WTFDudeSuite',_WTF)
