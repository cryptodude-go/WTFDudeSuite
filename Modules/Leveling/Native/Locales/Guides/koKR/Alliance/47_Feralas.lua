local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Alliance/47_Feralas.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "alliance-47-feralas", {
    ["Feralas (47-48)"] =
        "페랄라스 (47-48)",
    ["The Alliance stronghold of Feralas is on an island west of the zone."] =
        "페랄라스의 얼라이언스 요새는 지역 서쪽의 섬에 있습니다.",
    ["Feathermoon Stronghold"] =
        "페더문 요새",
    ["If the starting item dropped: use it from your bags."] =
        "시작 아이템을 얻었다면: 가방에서 사용하세요.",
})

end
_load('WTFDudeSuite',_WTF)
