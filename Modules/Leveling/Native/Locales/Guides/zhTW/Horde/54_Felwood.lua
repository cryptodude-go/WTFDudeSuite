local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/54_Felwood.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-54-felwood", {
    ["Felwood (51-53)"] =
        "費伍德森林 (51-53)",
    ["Felwood is north of Ashenvale: the Horde post is in the west of the zone."] =
        "費伍德森林位於梣谷北邊：部落崗哨在區域西部。",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完這一級再繼續。",
})

end
_load('WTFDudeSuite',_WTF)
