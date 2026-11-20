local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Alliance/29_Ashenvale.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "alliance-29-ashenvale", {
    ["Ashenvale (27-31)"] =
        "Vallefresno (27-31)",
    ["Back to Astranaar for the last Ashenvale quests. Finish the level on nearby monsters before moving on."] =
        "Vuelve a Astranaar para las últimas misiones de Vallefresno. Termina el nivel con monstruos cercanos antes de seguir.",
    ["Finish the level on nearby monsters before moving on."] =
        "Termina el nivel con monstruos cercanos antes de seguir.",
    ["Auberdine"] =
        "Auberdine",
})

end
_load('WTFDudeSuite',_WTF)
