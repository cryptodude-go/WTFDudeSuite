local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Horde/35_Stranglethorn.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "horde-35-stv", {
    ["Stranglethorn Vale (34-36)"] =
        "荆棘谷 (34-36)",
    ["Zeppelin from Orgrimmar to Grom'gol, the Horde camp in the north of Stranglethorn."] =
        "从奥格瑞玛乘飞艇到荆棘谷北部的部落营地格罗姆高。",
    ["Grom'gol"] =
        "格罗姆高营地",
    ["Booty Bay"] =
        "藏宝海湾",
})

end
_load('WTFDudeSuite',_WTF)
