local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Tauren/02_Mulgore.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "tauren-02-mulgore", {
    ["Mulgore (5-12)"] =
        "Mulgore (5-12)",
    ["Follow the road north out of Camp Narache to Bloodhoof Village: your base for Mulgore."] =
        "Sigue el camino al norte desde el Campamento Narache hasta el Poblado Pezuña de Sangre: tu base en Mulgore.",
    ["Bloodhoof Village"] =
        "Poblado Pezuña de Sangre",
})

end
_load('WTFDudeSuite',_WTF)
