local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/50_BlastedLands.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-50-blastedlands", {
    ["Blasted Lands (48-49)"] =
        "詛咒之地 (48-49)",
    ["Fly to the Blasted Lands, south of the Swamp of Sorrows: the Alliance keep in the north of the zone is your base."] =
        "飛往悲傷沼澤南邊的詛咒之地：區域北部的聯盟要塞就是你的據點。",
})

end
_load('WTFDudeSuite',_WTF)
