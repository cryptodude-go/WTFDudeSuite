local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/48_Hinterlands.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-48-hinterlands", {
    ["The Hinterlands (48-49)"] =
        "辛特蘭 (48-49)",
    ["The Hinterlands are east of Hillsbrad Foothills: the Revantusk troll village is on the east coast."] =
        "辛特蘭位於希爾斯布萊德丘陵東邊：食人妖的惡齒村在東岸。",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
    ["Revantusk Village"] =
        "惡齒村",
})

end
_load('WTFDudeSuite',_WTF)
