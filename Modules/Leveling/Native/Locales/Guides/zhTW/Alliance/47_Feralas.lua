local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/47_Feralas.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-47-feralas", {
    ["Feralas (47-48)"] =
        "菲拉斯 (47-48)",
    ["The Alliance stronghold of Feralas is on an island west of the zone."] =
        "聯盟在菲拉斯的要塞位於區域西邊的島上。",
    ["Feathermoon Stronghold"] =
        "羽月要塞",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
