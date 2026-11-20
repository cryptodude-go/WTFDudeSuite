local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Horde/43_SwampOfSorrows.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "horde-43-swamp", {
    ["Swamp of Sorrows (42)"] =
        "슬픔의 늪 (42)",
    ["The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base."] =
        "슬픔의 늪은 죽음의 고개 동쪽에 있습니다: 스토나드가 거점입니다.",
    ["Stonard"] =
        "스토나드",
})

end
_load('WTFDudeSuite',_WTF)
