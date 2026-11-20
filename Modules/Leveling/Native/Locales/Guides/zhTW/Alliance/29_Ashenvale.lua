local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/29_Ashenvale.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-29-ashenvale", {
    ["Ashenvale (27-31)"] =
        "梣谷 (27-31)",
    ["Back to Astranaar for the last Ashenvale quests. Finish the level on nearby monsters before moving on."] =
        "返回阿斯特蘭納，完成梣谷最後的任務。先在附近打怪升完這一級再繼續。",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完這一級再繼續。",
    ["Auberdine"] =
        "奧伯丁",
})

end
_load('WTFDudeSuite',_WTF)
