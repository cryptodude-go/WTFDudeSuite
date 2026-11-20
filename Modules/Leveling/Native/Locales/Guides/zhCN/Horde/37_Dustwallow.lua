local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Horde/37_Dustwallow.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "horde-37-dustwallow", {
    ["Dustwallow and Thousand Needles (36-37)"] =
        "尘泥沼泽和千针石林 (36-37)",
    ["Zeppelin back to Orgrimmar. Dustwallow Marsh is east of the southern Barrens, with Brackenwall Village in the north of the marsh; the Shimmering Flats are in the east of Thousand Needles."] =
        "乘飞艇返回奥格瑞玛。尘泥沼泽在贫瘠之地南部以东，蕨墙村在沼泽北部；闪光平原在千针石林东部。",
})

end
_load('WTFDudeSuite',_WTF)
