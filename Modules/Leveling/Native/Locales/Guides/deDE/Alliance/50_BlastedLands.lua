local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/50_BlastedLands.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-50-blastedlands", {
    ["Blasted Lands (48-49)"] =
        "Verwüstete Lande (48-49)",
    ["Fly to the Blasted Lands, south of the Swamp of Sorrows: the Alliance keep in the north of the zone is your base."] =
        "Flieg in die Verwüsteten Lande, südlich der Sümpfe des Elends: Die Festung der Allianz im Norden des Gebiets ist deine Basis.",
})

end
_load('WTFDudeSuite',_WTF)
