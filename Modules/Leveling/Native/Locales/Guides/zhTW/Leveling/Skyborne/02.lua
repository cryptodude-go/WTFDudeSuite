local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Leveling/Skyborne/02.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "leveling-s02-skyborne-horde", {
    ["Skyborne start (1-13)"] =
        "Skyborne起始區 (1-13)",
    ["Everything starts on Zephras Isle: follow the arrow from NPC to NPC."] =
        "一切從Zephras Isle開始：跟著箭頭逐一找NPC。",
    ["Coriella Calmbreeze"] =
        "Coriella Calmbreeze",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完這一級再繼續。",
    ["Donaal Downbreeze"] =
        "Donaal Downbreeze",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
