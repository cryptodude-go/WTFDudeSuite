local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Human/04_LochModan.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "human-04-lochmodan", {
    ["Loch Modan (16-18)"] =
        "洛克莫丹 (16-18)",
    ["Take the Deeprun Tram from Stormwind to Ironforge, then the road east through Dun Morogh to Thelsamar."] =
        "從暴風城搭礦道地鐵到鐵爐堡，再沿東邊道路穿過丹莫洛前往塞爾薩瑪。",
    ["Thelsamar"] =
        "塞爾薩瑪",
})

end
_load('WTFDudeSuite',_WTF)
