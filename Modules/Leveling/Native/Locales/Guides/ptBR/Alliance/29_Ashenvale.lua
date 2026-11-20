local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/Alliance/29_Ashenvale.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "alliance-29-ashenvale", {
    ["Ashenvale (27-31)"] =
        "Vale Gris (27-31)",
    ["Back to Astranaar for the last Ashenvale quests. Finish the level on nearby monsters before moving on."] =
        "De volta a Astranaar para as últimas missões do Vale Gris. Termine o nível nos monstros próximos antes de seguir.",
    ["Finish the level on nearby monsters before moving on."] =
        "Termine o nível nos monstros próximos antes de seguir.",
    ["Auberdine"] =
        "Auberdine",
})

end
_load('WTFDudeSuite',_WTF)
