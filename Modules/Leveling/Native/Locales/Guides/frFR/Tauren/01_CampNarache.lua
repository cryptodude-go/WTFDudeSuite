local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Tauren/01_CampNarache.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "tauren-01-narache", {
    ["Camp Narache (1-5)"] =
        "Camp Narache (1-5)",
    ["Everything starts at Camp Narache: follow the arrow from NPC to NPC."] =
        "Tout commence au camp Narache : suis la flèche de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
