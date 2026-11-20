local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Horde/33_Desolace.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "horde-33-desolace", {
    ["Desolace (32-34)"] =
        "Desolace (32-34)",
    ["Desolace is south of the Stonetalon Mountains: the Horde village is on the west coast. Finish the level on nearby monsters before moving on."] =
        "Desolace está al sur de la Sierra Espolón: el poblado de la Horda está en la costa oeste. Termina el nivel con monstruos cercanos antes de seguir.",
    ["Shadowprey Village"] =
        "Aldea Cazasombras",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
})

end
_load('WTFDudeSuite',_WTF)
