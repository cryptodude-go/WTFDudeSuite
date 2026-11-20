local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Alliance/42_SwampOfSorrows.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "alliance-42-swamp", {
    ["Swamp of Sorrows (41)"] =
        "슬픔의 늪 (41)",
    ["The Swamp of Sorrows is east of Deadwind Pass, south of Redridge."] =
        "슬픔의 늪은 죽음의 고개 동쪽, 붉은마루 산맥 남쪽에 있습니다.",
})

end
_load('WTFDudeSuite',_WTF)
