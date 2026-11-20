local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/22_Duskwood.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-22-duskwood", {
    ["Duskwood (19-20)"] =
        "暮色森林 (19-20)",
    ["Duskwood is south of Elwynn: Darkshire, in the east of the forest, is your base."] =
        "暮色森林在艾尔文森林以南：森林东部的夜色镇是据点。",
    ["Darkshire"] =
        "夜色镇",
})

end
_load('WTFDudeSuite',_WTF)
