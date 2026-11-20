local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/26_Ashenvale.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-26-ashenvale", {
    ["Ashenvale (26-27)"] =
        "梣谷 (26-27)",
    ["Boat from Menethil to Auberdine, then the road south to Ashenvale: Astranaar is your base."] =
        "從米奈希爾港搭船到奧伯丁，再沿南邊道路前往梣谷：據點是阿斯特蘭納。",
    ["Astranaar"] =
        "阿斯特蘭納",
})

end
_load('WTFDudeSuite',_WTF)
