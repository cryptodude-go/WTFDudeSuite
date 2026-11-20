local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/43_Stranglethorn.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-43-stv", {
    ["Stranglethorn Vale (41)"] =
        "荊棘谷 (41)",
    ["Back to Stranglethorn for the end of its quests, from Booty Bay."] =
        "返回荊棘谷，從藏寶海灣出發完成剩下的任務。",
    ["Booty Bay"] =
        "藏寶海灣",
})

end
_load('WTFDudeSuite',_WTF)
