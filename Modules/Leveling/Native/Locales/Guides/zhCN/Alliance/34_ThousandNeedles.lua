local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/34_ThousandNeedles.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-34-needles", {
    ["Thousand Needles (34)"] =
        "千针石林 (34)",
    ["Reach Thousand Needles through Theramore and the southern Barrens, or through Feralas; the goblin camp in the east is your base."] =
        "经塞拉摩和贫瘠之地南部，或经菲拉斯前往千针石林；东部的地精营地是据点。",
})

end
_load('WTFDudeSuite',_WTF)
