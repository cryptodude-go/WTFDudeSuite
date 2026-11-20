local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Horde/35_Stranglethorn.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "horde-35-stv", {
    ["Stranglethorn Vale (34-36)"] =
        "가시덤불 골짜기 (34-36)",
    ["Zeppelin from Orgrimmar to Grom'gol, the Horde camp in the north of Stranglethorn."] =
        "오그리마에서 비행선을 타고 가시덤불 골짜기 북쪽의 호드 야영지인 그롬골 주둔지로 가세요.",
    ["Grom'gol"] =
        "그롬골 주둔지",
    ["Booty Bay"] =
        "무법항",
})

end
_load('WTFDudeSuite',_WTF)
