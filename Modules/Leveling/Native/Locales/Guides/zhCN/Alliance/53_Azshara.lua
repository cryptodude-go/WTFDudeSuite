local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/53_Azshara.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-53-azshara", {
    ["Azshara (51)"] =
        "艾萨拉 (51)",
    ["Azshara is east of Ashenvale."] =
        "艾萨拉在灰谷以东。",
})

end
_load('WTFDudeSuite',_WTF)
