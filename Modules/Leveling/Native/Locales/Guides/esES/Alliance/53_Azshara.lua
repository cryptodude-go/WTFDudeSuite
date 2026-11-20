local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/53_Azshara.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-53-azshara", {
    ["Azshara (51)"] =
        "Azshara (51)",
    ["Azshara is east of Ashenvale."] =
        "Azshara está al este de Vallefresno.",
})

end
_load('WTFDudeSuite',_WTF)
