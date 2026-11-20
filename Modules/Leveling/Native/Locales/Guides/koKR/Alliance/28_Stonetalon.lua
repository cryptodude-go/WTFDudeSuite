local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Alliance/28_Stonetalon.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "돌발톱 산맥 (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "돌발톱 산맥은 잿빛 골짜기 서쪽에 있습니다.",
    ["Stonetalon Peak"] =
        "돌발톱 봉우리",
})

end
_load('WTFDudeSuite',_WTF)
