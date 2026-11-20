local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/39_Arathi.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-39-arathi", {
    ["Arathi Highlands (39-40)"] =
        "阿拉希高地 (39-40)",
    ["The Arathi Highlands are north of the Wetlands, across Thandol Span."] =
        "阿拉希高地在湿地以北，跨过萨多尔大桥即到。",
    ["If the starting item dropped: use it from your bags."] =
        "如果掉落了任务起始物品：在背包中使用。",
})

end
_load('WTFDudeSuite',_WTF)
