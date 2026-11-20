local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/53_Azshara.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-53-azshara", {
    ["Azshara (51)"] =
        "Azshara (51)",
    ["Azshara is east of Ashenvale."] =
        "Azshara est à l'est d'Orneval.",
})

end
_load('WTFDudeSuite',_WTF)
