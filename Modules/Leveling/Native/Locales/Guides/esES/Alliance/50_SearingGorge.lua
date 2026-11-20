local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/50_SearingGorge.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-50-searinggorge", {
    ["Searing Gorge (48)"] =
        "La Garganta de Fuego (48)",
    ["Searing Gorge is south of Loch Modan, through the Badlands."] =
        "La Garganta de Fuego está al sur de Loch Modan, tras las Tierras Inhóspitas.",
    ["If the starting item dropped: use it from your bags."] =
        "Si tienes el objeto que inicia la misión: úsalo desde tus bolsas.",
})

end
_load('WTFDudeSuite',_WTF)
