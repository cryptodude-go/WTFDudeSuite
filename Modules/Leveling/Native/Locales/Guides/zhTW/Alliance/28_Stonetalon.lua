local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/28_Stonetalon.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "石爪山脈 (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "石爪山脈位於梣谷西邊。",
    ["Stonetalon Peak"] =
        "石爪峰",
})

end
_load('WTFDudeSuite',_WTF)
