local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/NightElf/04_LochModan.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "nightelf-04-lochmodan", {
    ["Loch Modan (19-21)"] =
        "洛克莫丹 (19-21)",
    ["Boat from Auberdine to Menethil Harbor, then the road east through the Wetlands to Loch Modan: Thelsamar is your base."] =
        "從奧伯丁搭船到米奈希爾港，再沿東邊道路穿過濕地前往洛克莫丹：據點是塞爾薩瑪。",
    ["Thelsamar"] =
        "塞爾薩瑪",
})

end
_load('WTFDudeSuite',_WTF)
