local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/22_Duskwood.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-22-duskwood", {
    ["Duskwood (19-20)"] =
        "暮色森林 (19-20)",
    ["Duskwood is south of Elwynn: Darkshire, in the east of the forest, is your base."] =
        "暮色森林位於艾爾文森林南邊：據點是森林東部的夜色鎮。",
    ["Darkshire"] =
        "夜色鎮",
})

end
_load('WTFDudeSuite',_WTF)
