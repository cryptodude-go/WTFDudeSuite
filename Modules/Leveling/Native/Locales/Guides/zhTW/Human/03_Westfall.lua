local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Human/03_Westfall.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "human-03-westfall", {
    ["Westfall (12-16)"] =
        "西部荒野 (12-16)",
    ["Head west on the Goldshire road, then to Sentinel Hill in the middle of Westfall."] =
        "沿閃金鎮的道路往西，再前往西部荒野中央的哨兵嶺。",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
    ["Sentinel Hill"] =
        "哨兵嶺",
})

end
_load('WTFDudeSuite',_WTF)
