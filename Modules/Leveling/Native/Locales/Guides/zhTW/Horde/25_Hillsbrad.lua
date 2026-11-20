local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/25_Hillsbrad.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-25-hillsbrad", {
    ["Hillsbrad Foothills (25-27)"] =
        "希爾斯布萊德丘陵 (25-27)",
    ["Zeppelin from the tower outside Orgrimmar to Undercity, then the road south through Silverpine Forest to Tarren Mill: your base."] =
        "從奧格瑪外的飛艇塔搭飛艇到幽暗城，再沿南邊道路穿過銀松森林，前往據點塔倫米爾。",
    ["Tarren Mill"] =
        "塔倫米爾",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
