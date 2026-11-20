local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Horde/29_ThousandNeedles.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "horde-29-needles", {
    ["Thousand Needles (28-30)"] =
        "千针石林 (28-30)",
    ["Thousand Needles is south of the Barrens, down the Great Lift: Freewind Post is your base."] =
        "千针石林在贫瘠之地以南，乘升降梯下去：乱风岗是据点。",
    ["Freewind Post"] =
        "乱风岗",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完这一级再继续。",
})

end
_load('WTFDudeSuite',_WTF)
