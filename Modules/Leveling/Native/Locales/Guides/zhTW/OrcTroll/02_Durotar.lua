local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/OrcTroll/02_Durotar.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "orc-02-durotar", {
    ["Durotar (5-11)"] =
        "杜洛塔 (5-11)",
    ["Leave the valley by the road east, then north to Razor Hill: your base for Durotar."] =
        "沿東邊道路離開山谷，再往北前往杜洛塔的據點剃刀嶺。",
    ["Razor Hill"] =
        "剃刀嶺",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
