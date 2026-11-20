local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/50_BlastedLands.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-50-blastedlands", {
    ["Blasted Lands (48-49)"] =
        "Las Tierras Devastadas (48-49)",
    ["Fly to the Blasted Lands, south of the Swamp of Sorrows: the Alliance keep in the north of the zone is your base."] =
        "Vuela a Las Tierras Devastadas, al sur del Pantano de las Penas: la fortaleza de la Alianza, al norte de la zona, es tu base.",
})

end
_load('WTFDudeSuite',_WTF)
