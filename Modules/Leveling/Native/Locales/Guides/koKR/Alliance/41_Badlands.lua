local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Alliance/41_Badlands.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "황야의 땅 (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "황야의 땅은 모단 호수 남동쪽에 있습니다.",
})

end
_load('WTFDudeSuite',_WTF)
