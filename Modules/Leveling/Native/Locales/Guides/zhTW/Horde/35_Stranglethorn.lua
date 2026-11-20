local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/35_Stranglethorn.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-35-stv", {
    ["Stranglethorn Vale (34-36)"] =
        "荊棘谷 (34-36)",
    ["Zeppelin from Orgrimmar to Grom'gol, the Horde camp in the north of Stranglethorn."] =
        "從奧格瑪搭飛艇到荊棘谷北部的部落據點格羅姆高營地。",
    ["Grom'gol"] =
        "格羅姆高營地",
    ["Booty Bay"] =
        "藏寶海灣",
})

end
_load('WTFDudeSuite',_WTF)
