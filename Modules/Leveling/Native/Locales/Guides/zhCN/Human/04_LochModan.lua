local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Human/04_LochModan.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "human-04-lochmodan", {
    ["Loch Modan (16-18)"] =
        "洛克莫丹 (16-18)",
    ["Take the Deeprun Tram from Stormwind to Ironforge, then the road east through Dun Morogh to Thelsamar."] =
        "在暴风城乘坐矿道地铁到铁炉堡，再沿东边的道路穿过丹莫罗到塞尔萨玛。",
    ["Thelsamar"] =
        "塞尔萨玛",
})

end
_load('WTFDudeSuite',_WTF)
