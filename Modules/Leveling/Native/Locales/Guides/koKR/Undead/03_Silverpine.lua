local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "koKR" then return end -- Skip inactive-language allocations.
-- Korean text of Guides/Undead/03_Silverpine.lua: [English text] = Korean text.
-- Written by tools/translate_guides.lua from tools/routes/locales/koKR.lua.
Ding.RegisterGuideTranslation("koKR", "undead-03-silverpine", {
    ["Silverpine Forest (13-15)"] =
        "은빛소나무 숲 (13-15)",
    ["From Brill, take the road west then south over the bridge into Silverpine Forest: the Sepulcher is your base."] =
        "브릴에서 서쪽 길로 간 다음, 남쪽으로 다리를 건너 은빛소나무 숲으로 가세요: 공동묘지가 거점입니다.",
    ["The Sepulcher"] =
        "공동묘지",
})

end
_load('WTFDudeSuite',_WTF)
