local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/23_Ashenvale.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-23-ashenvale", {
    ["Ashenvale (20-25)"] =
        "Vallefresno (20-25)",
    ["Ashenvale is north of the Barrens: Splintertree Post, in the east of the forest, is your base."] =
        "Vallefresno está al norte de Los Baldíos: el Puesto del Hachazo, al este del bosque, es tu base.",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
    ["Splintertree Post"] =
        "Puesto del Hachazo",
})

end
_load('WTFDudeSuite',_WTF)
