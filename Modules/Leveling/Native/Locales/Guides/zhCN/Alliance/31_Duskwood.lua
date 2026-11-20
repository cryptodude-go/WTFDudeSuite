local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/31_Duskwood.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-31-duskwood", {
    ["Duskwood (31-32)"] =
        "暮色森林 (31-32)",
    ["Back to Duskwood for the end of its quests: Darkshire is still your base."] =
        "返回暮色森林完成剩余任务：据点仍是夜色镇。",
    ["Darkshire"] =
        "夜色镇",
})

end
_load('WTFDudeSuite',_WTF)
