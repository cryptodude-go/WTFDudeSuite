local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/50_BlastedLands.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-50-blastedlands", {
    ["Blasted Lands (48-49)"] =
        "Barreira do Inferno (48-49)",
    ["Fly to the Blasted Lands, south of the Swamp of Sorrows: the Alliance keep in the north of the zone is your base."] =
        "Voe até a Barreira do Inferno, ao sul do Pântano das Mágoas: a fortaleza da Aliança, no norte da zona, é a sua base.",
})

end
_load('WTFDudeSuite',_WTF)
