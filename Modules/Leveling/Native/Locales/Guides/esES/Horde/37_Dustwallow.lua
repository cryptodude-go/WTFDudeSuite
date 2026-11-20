local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/37_Dustwallow.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-37-dustwallow", {
    ["Dustwallow and Thousand Needles (36-37)"] =
        "Revolcafango y Las Mil Agujas (36-37)",
    ["Zeppelin back to Orgrimmar. Dustwallow Marsh is east of the southern Barrens, with Brackenwall Village in the north of the marsh; the Shimmering Flats are in the east of Thousand Needles."] =
        "Zepelín de vuelta a Orgrimmar. El Marjal Revolcafango está al este del sur de Los Baldíos, con el Poblado Murohelecho al norte del marjal; Shimmering Flats está al este de Las Mil Agujas.",
})

end
_load('WTFDudeSuite',_WTF)
