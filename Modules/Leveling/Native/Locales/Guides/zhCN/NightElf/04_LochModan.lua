local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/NightElf/04_LochModan.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "nightelf-04-lochmodan", {
    ["Loch Modan (19-21)"] =
        "洛克莫丹 (19-21)",
    ["Boat from Auberdine to Menethil Harbor, then the road east through the Wetlands to Loch Modan: Thelsamar is your base."] =
        "从奥伯丁坐船到米奈希尔港，再沿东边的道路穿过湿地到洛克莫丹：塞尔萨玛是据点。",
    ["Thelsamar"] =
        "塞尔萨玛",
})

end
_load('WTFDudeSuite',_WTF)
