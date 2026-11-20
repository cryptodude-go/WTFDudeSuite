local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/50_SearingGorge.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-50-searinggorge", {
    ["Searing Gorge (48)"] =
        "灼熱峽谷 (48)",
    ["Searing Gorge is south of Loch Modan, through the Badlands."] =
        "灼熱峽谷位於洛克莫丹南邊，經荒蕪之地前往。",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
