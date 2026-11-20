local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/59_Silithus.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-59-silithus", {
    ["Silithus (56-60)"] =
        "Silithus (56-60)",
    ["Silithus is south of Un'Goro Crater: Cenarion Hold is in the north of the zone."] =
        "Silithus está al sur del Cráter de Un'Goro: el Fuerte Cenarion está al norte de la zona.",
    ["Cenarion Hold"] =
        "Fuerte Cenarion",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
})

end
_load('WTFDudeSuite',_WTF)
