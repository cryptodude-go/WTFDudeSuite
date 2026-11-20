local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/DwarfGnome/04_Westfall.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "dwarf-04-westfall", {
    ["Westfall (14-18)"] =
        "西部荒野 (14-18)",
    ["Deeprun Tram from Ironforge to Stormwind, then the road west through Goldshire to Sentinel Hill."] =
        "從鐵爐堡搭礦道地鐵到暴風城，再沿西邊道路經閃金鎮前往哨兵嶺。",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
    ["Sentinel Hill"] =
        "哨兵嶺",
})

end
_load('WTFDudeSuite',_WTF)
