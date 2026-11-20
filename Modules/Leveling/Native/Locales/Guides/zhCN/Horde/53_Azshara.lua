local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Horde/53_Azshara.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "horde-53-azshara", {
    ["Azshara (51)"] =
        "艾萨拉 (51)",
    ["Azshara is east of Ashenvale: Valormok, in the southwest of the zone, is your base."] =
        "艾萨拉在灰谷以东：该区域西南部的瓦罗莫克是据点。",
})

end
_load('WTFDudeSuite',_WTF)
