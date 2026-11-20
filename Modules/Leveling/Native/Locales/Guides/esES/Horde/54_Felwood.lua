local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/54_Felwood.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-54-felwood", {
    ["Felwood (51-53)"] =
        "Frondavil (51-53)",
    ["Felwood is north of Ashenvale: the Horde post is in the west of the zone."] =
        "Frondavil está al norte de Vallefresno: el puesto de la Horda está al oeste de la zona.",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
})

end
_load('WTFDudeSuite',_WTF)
