local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Horde/40_Badlands.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "horde-40-badlands", {
    ["Badlands (38)"] =
        "荒芜之地 (38)",
    ["Fly from Hammerfall to Kargath, in the west of the Badlands."] =
        "从落锤镇飞往荒芜之地西部的卡加斯。",
    ["Kargath"] =
        "卡加斯",
})

end
_load('WTFDudeSuite',_WTF)
