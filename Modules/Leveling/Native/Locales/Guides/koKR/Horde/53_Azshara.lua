local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Horde/53_Azshara.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "horde-53-azshara", {
    ["Azshara (51)"] =
        "아즈샤라 (51)",
    ["Azshara is east of Ashenvale: Valormok, in the southwest of the zone, is your base."] =
        "아즈샤라는 잿빛 골짜기 동쪽에 있습니다: 지역 남서쪽의 발로르모크가 거점입니다.",
})

end
_load('WTFDudeSuite',_WTF)
