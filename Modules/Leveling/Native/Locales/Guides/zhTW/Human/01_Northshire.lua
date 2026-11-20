local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Human/01_Northshire.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "human-01-northshire", {
    ["Northshire (1-5)"] =
        "北郡 (1-5)",
    ["Everything happens around Northshire Abbey: follow the arrow from NPC to NPC."] =
        "一切都在北郡修道院周圍進行：跟著箭頭逐一找NPC。",
})

end
_load('WTFDudeSuite',_WTF)
