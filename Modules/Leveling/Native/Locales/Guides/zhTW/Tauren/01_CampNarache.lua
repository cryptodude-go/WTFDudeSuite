local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Tauren/01_CampNarache.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "tauren-01-narache", {
    ["Camp Narache (1-5)"] =
        "納拉其營地 (1-5)",
    ["Everything starts at Camp Narache: follow the arrow from NPC to NPC."] =
        "一切從納拉其營地開始：跟著箭頭逐一找NPC。",
})

end
_load('WTFDudeSuite',_WTF)
