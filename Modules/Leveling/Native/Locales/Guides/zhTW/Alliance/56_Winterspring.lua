local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/56_Winterspring.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-56-winterspring", {
    ["Winterspring (54)"] =
        "冬泉谷 (54)",
    ["Winterspring is northeast of Felwood: Everlook is your base."] =
        "冬泉谷位於費伍德森林東北邊：據點是永望鎮。",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
