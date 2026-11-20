local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/Tauren/01_CampNarache.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "tauren-01-narache", {
    ["Camp Narache (1-5)"] =
        "纳拉其营地 (1-5)",
    ["Everything starts at Camp Narache: follow the arrow from NPC to NPC."] =
        "一切从纳拉其营地开始：跟随箭头逐个找NPC。",
})

end
_load('WTFDudeSuite',_WTF)
