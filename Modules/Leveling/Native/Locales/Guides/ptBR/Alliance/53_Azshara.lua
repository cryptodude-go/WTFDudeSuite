local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/53_Azshara.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-53-azshara", {
    ["Azshara (51)"] =
        "Azshara (51)",
    ["Azshara is east of Ashenvale."] =
        "Azshara fica a leste do Vale Gris.",
})

end
_load('WTFDudeSuite',_WTF)
