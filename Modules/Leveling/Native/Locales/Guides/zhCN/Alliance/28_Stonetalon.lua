local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/28_Stonetalon.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "石爪山脉 (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "石爪山脉在灰谷以西。",
    ["Stonetalon Peak"] =
        "石爪峰",
})

end
_load('WTFDudeSuite',_WTF)
