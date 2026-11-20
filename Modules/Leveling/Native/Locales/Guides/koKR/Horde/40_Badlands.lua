local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Horde/40_Badlands.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "horde-40-badlands", {
    ["Badlands (38)"] =
        "황야의 땅 (38)",
    ["Fly from Hammerfall to Kargath, in the west of the Badlands."] =
        "해머폴에서 황야의 땅 서쪽의 카르가스로 날아가세요.",
    ["Kargath"] =
        "카르가스",
})

end
_load('WTFDudeSuite',_WTF)
