local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Undead/04_Barrens.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "undead-04-barrens", {
    ["The Barrens (15-20)"] =
        "貧瘠之地 (15-20)",
    ["Zeppelin from the towers outside Undercity to Orgrimmar, then the road west and south to the Crossroads: your base for the Barrens."] =
        "從幽暗城外的飛艇塔搭飛艇到奧格瑪，再沿道路往西、往南前往貧瘠之地的據點十字路口。",
    ["The Crossroads"] =
        "十字路口",
})

end
_load('WTFDudeSuite',_WTF)
