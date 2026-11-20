local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/27_Barrens.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-27-barrens", {
    ["The Barrens and Stonetalon (27-28)"] =
        "貧瘠之地與石爪山脈 (27-28)",
    ["Zeppelin back to Orgrimmar for the higher quests of the Barrens and the Stonetalon Mountains."] =
        "搭飛艇返回奧格瑪，進行貧瘠之地和石爪山脈等級較高的任務。",
    ["Sun Rock Retreat"] =
        "烈日石居",
    ["Camp Taurajo"] =
        "陶拉祖營地",
})

end
_load('WTFDudeSuite',_WTF)
