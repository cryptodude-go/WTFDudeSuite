local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/41_Badlands.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-41-badlands", {
    ["Badlands (40-41)"] =
        "荒蕪之地 (40-41)",
    ["The Badlands are southeast of Loch Modan."] =
        "荒蕪之地位於洛克莫丹東南邊。",
})

end
_load('WTFDudeSuite',_WTF)
