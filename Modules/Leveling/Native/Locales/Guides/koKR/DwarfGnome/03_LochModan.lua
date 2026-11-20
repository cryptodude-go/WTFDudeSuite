local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/DwarfGnome/03_LochModan.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "dwarf-03-lochmodan", {
    ["Loch Modan (11-14)"] =
        "모단 호수 (11-14)",
    ["Take the road east through the South Gate tunnel to Thelsamar."] =
        "남부 관문 터널을 지나는 동쪽 길로 텔사마까지 가세요.",
    ["Thelsamar"] =
        "텔사마",
    ["Finish the level on nearby monsters before moving on."] =
        "다음으로 넘어가기 전에 주변 몬스터로 레벨을 마저 올리세요.",
})

end
_load('WTFDudeSuite',_WTF)
