local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/53_Azshara.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-53-azshara", {
    ["Azshara (51)"] =
        "艾薩拉 (51)",
    ["Azshara is east of Ashenvale."] =
        "艾薩拉位於梣谷東邊。",
})

end
_load('WTFDudeSuite',_WTF)
