local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhCN" then return end -- Skip inactive-language allocations.
-- Simplified Chinese text of Guides/DwarfGnome/01_Coldridge.lua: [English text] = Simplified Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhCN.lua.
Ding.RegisterGuideTranslation("zhCN", "dwarf-01-coldridge", {
    ["Coldridge Valley (1-5)"] =
        "寒脊山谷 (1-5)",
    ["Everything starts in Coldridge: follow the arrow from NPC to NPC."] =
        "一切从寒脊山谷开始：跟随箭头逐个找NPC。",
})

end
_load('WTFDudeSuite',_WTF)
