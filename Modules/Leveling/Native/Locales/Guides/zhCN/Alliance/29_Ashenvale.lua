local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/29_Ashenvale.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-29-ashenvale", {
    ["Ashenvale (27-31)"] =
        "灰谷 (27-31)",
    ["Back to Astranaar for the last Ashenvale quests. Finish the level on nearby monsters before moving on."] =
        "返回阿斯特兰纳，完成灰谷最后的任务。先在附近打怪升完这一级再继续。",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完这一级再继续。",
    ["Auberdine"] =
        "奥伯丁",
})

end
_load('WTFDudeSuite',_WTF)
