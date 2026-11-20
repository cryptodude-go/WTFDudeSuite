local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/55_BurningSteppes.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-55-burningsteppes", {
    ["Burning Steppes (54)"] =
        "燃烧平原 (54)",
    ["The Burning Steppes are north of Redridge: the Alliance camp is in the east of the zone."] =
        "燃烧平原在赤脊山以北：联盟营地在该区域东部。",
})

end
_load('WTFDudeSuite',_WTF)
