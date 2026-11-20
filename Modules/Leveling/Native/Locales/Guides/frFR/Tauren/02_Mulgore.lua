local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Tauren/02_Mulgore.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "tauren-02-mulgore", {
    ["Mulgore (5-12)"] =
        "Mulgore (5-12)",
    ["Follow the road north out of Camp Narache to Bloodhoof Village: your base for Mulgore."] =
        "Suis la route du nord depuis le camp Narache jusqu'au village de Sabot-de-Sang : c'est ta base pour Mulgore.",
    ["Bloodhoof Village"] =
        "Village de Sabot-de-Sang",
})

end
_load('WTFDudeSuite',_WTF)
