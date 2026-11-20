local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/26_Ashenvale.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-26-ashenvale", {
    ["Ashenvale (26-27)"] =
        "灰谷 (26-27)",
    ["Boat from Menethil to Auberdine, then the road south to Ashenvale: Astranaar is your base."] =
        "从米奈希尔港坐船到奥伯丁，再沿南边的道路到灰谷：阿斯特兰纳是据点。",
    ["Astranaar"] =
        "阿斯特兰纳",
})

end
_load('WTFDudeSuite',_WTF)
