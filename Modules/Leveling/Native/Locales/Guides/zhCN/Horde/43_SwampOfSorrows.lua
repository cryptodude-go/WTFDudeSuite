local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Horde/43_SwampOfSorrows.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "horde-43-swamp", {
    ["Swamp of Sorrows (42)"] =
        "悲伤沼泽 (42)",
    ["The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base."] =
        "悲伤沼泽在逆风小径以东：斯通纳德是据点。",
    ["Stonard"] =
        "斯通纳德",
})

end
_load('WTFDudeSuite',_WTF)
