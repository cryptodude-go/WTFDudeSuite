local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/20_Barrens.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-20-barrens", {
    ["The Barrens and Stonetalon (19-20)"] =
        "貧瘠之地與石爪山脈 (19-20)",
    ["The Crossroads, in the middle of the Barrens, is your base; the Stonetalon Mountains are west of the Barrens."] =
        "據點是貧瘠之地中央的十字路口；石爪山脈位於貧瘠之地西邊。",
    ["Ratchet"] =
        "棘齒城",
    ["Sun Rock Retreat"] =
        "烈日石居",
})

end
_load('WTFDudeSuite',_WTF)
