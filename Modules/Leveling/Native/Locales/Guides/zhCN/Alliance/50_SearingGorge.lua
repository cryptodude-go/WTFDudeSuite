local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/50_SearingGorge.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-50-searinggorge", {
    ["Searing Gorge (48)"] =
        "灼热峡谷 (48)",
    ["Searing Gorge is south of Loch Modan, through the Badlands."] =
        "灼热峡谷在洛克莫丹以南，需穿过荒芜之地。",
    ["If the starting item dropped: use it from your bags."] =
        "如果掉落了任务起始物品：在背包中使用。",
})

end
_load('WTFDudeSuite',_WTF)
