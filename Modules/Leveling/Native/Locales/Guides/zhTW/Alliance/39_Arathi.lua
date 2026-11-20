local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/39_Arathi.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-39-arathi", {
    ["Arathi Highlands (39-40)"] =
        "阿拉希高地 (39-40)",
    ["The Arathi Highlands are north of the Wetlands, across Thandol Span."] =
        "阿拉希高地位於濕地北邊，過薩多爾大橋即達。",
    ["If the starting item dropped: use it from your bags."] =
        "若掉落了開始任務的物品：從背包使用。",
})

end
_load('WTFDudeSuite',_WTF)
