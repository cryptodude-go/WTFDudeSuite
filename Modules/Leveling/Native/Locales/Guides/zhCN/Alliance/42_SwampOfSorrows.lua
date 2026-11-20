local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/42_SwampOfSorrows.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-42-swamp", {
    ["Swamp of Sorrows (41)"] =
        "悲伤沼泽 (41)",
    ["The Swamp of Sorrows is east of Deadwind Pass, south of Redridge."] =
        "悲伤沼泽在逆风小径以东、赤脊山以南。",
})

end
_load('WTFDudeSuite',_WTF)
