local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/29_ThousandNeedles.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-29-needles", {
    ["Thousand Needles (28-30)"] =
        "千針石林 (28-30)",
    ["Thousand Needles is south of the Barrens, down the Great Lift: Freewind Post is your base."] =
        "千針石林位於貧瘠之地南邊，搭升降梯下去即達：據點是亂風崗。",
    ["Freewind Post"] =
        "亂風崗",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完這一級再繼續。",
})

end
_load('WTFDudeSuite',_WTF)
