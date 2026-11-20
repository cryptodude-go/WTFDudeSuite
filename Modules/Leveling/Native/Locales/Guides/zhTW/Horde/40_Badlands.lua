local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/40_Badlands.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-40-badlands", {
    ["Badlands (38)"] =
        "荒蕪之地 (38)",
    ["Fly from Hammerfall to Kargath, in the west of the Badlands."] =
        "從落錘鎮飛往荒蕪之地西部的卡加斯。",
    ["Kargath"] =
        "卡加斯",
})

end
_load('WTFDudeSuite',_WTF)
