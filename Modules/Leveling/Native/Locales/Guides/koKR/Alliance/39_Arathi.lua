local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Alliance/39_Arathi.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "alliance-39-arathi", {
    ["Arathi Highlands (39-40)"] =
        "아라시 고원 (39-40)",
    ["The Arathi Highlands are north of the Wetlands, across Thandol Span."] =
        "아라시 고원은 탄돌 교각 건너편, 저습지 북쪽에 있습니다.",
    ["If the starting item dropped: use it from your bags."] =
        "시작 아이템을 얻었다면: 가방에서 사용하세요.",
})

end
_load('WTFDudeSuite',_WTF)
