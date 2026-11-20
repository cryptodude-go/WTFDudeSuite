local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/56_Winterspring.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-56-winterspring", {
    ["Winterspring (54)"] =
        "Cuna del Invierno (54)",
    ["Winterspring is northeast of Felwood: Everlook is your base."] =
        "Cuna del Invierno está al noreste de Frondavil: Vista Eterna es tu base.",
    ["If the starting item dropped: use it from your bags."] =
        "Si tienes el objeto que inicia la misión: úsalo desde tus bolsas.",
})

end
_load('WTFDudeSuite',_WTF)
