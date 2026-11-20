local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/55_BurningSteppes.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-55-burningsteppes", {
    ["Burning Steppes (54)"] =
        "燃燒平原 (54)",
    ["The Burning Steppes are north of Redridge: the Alliance camp is in the east of the zone."] =
        "燃燒平原位於赤脊山北邊：聯盟營地在區域東部。",
})

end
_load('WTFDudeSuite',_WTF)
