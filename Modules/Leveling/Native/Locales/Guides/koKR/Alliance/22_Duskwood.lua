local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Alliance/22_Duskwood.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "alliance-22-duskwood", {
    ["Duskwood (19-20)"] =
        "그늘숲 (19-20)",
    ["Duskwood is south of Elwynn: Darkshire, in the east of the forest, is your base."] =
        "그늘숲은 엘윈 숲 남쪽에 있습니다: 숲 동쪽의 다크샤이어가 거점입니다.",
    ["Darkshire"] =
        "다크샤이어",
})

end
_load('WTFDudeSuite',_WTF)
