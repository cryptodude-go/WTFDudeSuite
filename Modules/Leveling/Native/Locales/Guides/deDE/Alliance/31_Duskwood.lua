local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/31_Duskwood.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-31-duskwood", {
    ["Duskwood (31-32)"] =
        "Dämmerwald (31-32)",
    ["Back to Duskwood for the end of its quests: Darkshire is still your base."] =
        "Zurück in den Dämmerwald für seine letzten Quests: Dunkelhain bleibt deine Basis.",
    ["Darkshire"] =
        "Dunkelhain",
})

end
_load('WTFDudeSuite',_WTF)
