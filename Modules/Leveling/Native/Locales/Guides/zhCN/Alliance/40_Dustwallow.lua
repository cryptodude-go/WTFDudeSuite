local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/40_Dustwallow.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-40-dustwallow", {
    ["Dustwallow Marsh (40)"] =
        "尘泥沼泽 (40)",
    ["Boat from Menethil to Theramore, the Alliance base on the edge of the marsh."] =
        "从米奈希尔港坐船到沼泽边缘的联盟据点塞拉摩。",
    ["Theramore"] =
        "塞拉摩",
})

end
_load('WTFDudeSuite',_WTF)
