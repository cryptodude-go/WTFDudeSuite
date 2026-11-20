local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Alliance/57_WesternPlaguelands.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "alliance-57-wpl", {
    ["Western Plaguelands (54-55)"] =
        "西瘟疫之地 (54-55)",
    ["The Western Plaguelands are north of Hillsbrad Foothills: the Alliance camp is in the south of the zone."] =
        "西瘟疫之地在希尔斯布莱德丘陵以北：联盟营地在该区域南部。",
    ["Ironforge"] =
        "铁炉堡",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完这一级再继续。",
})

end
_load('WTFDudeSuite',_WTF)
