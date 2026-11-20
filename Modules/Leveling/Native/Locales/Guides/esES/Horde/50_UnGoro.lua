local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/50_UnGoro.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-50-ungoro", {
    ["Un'Goro Crater (50-51)"] =
        "Cráter de Un'Goro (50-51)",
    ["Un'Goro Crater opens southwest of Tanaris: take the ramp down from Gadgetzan."] =
        "El Cráter de Un'Goro se abre al suroeste de Tanaris: baja por la rampa desde Gadgetzan.",
    ["If the starting item dropped: use it from your bags."] =
        "Si tienes el objeto que inicia la misión: úsalo desde tus bolsas.",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
})

end
_load('WTFDudeSuite',_WTF)
