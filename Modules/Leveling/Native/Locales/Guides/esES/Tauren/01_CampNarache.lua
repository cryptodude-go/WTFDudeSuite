local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Tauren/01_CampNarache.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "tauren-01-narache", {
    ["Camp Narache (1-5)"] =
        "Campamento Narache (1-5)",
    ["Everything starts at Camp Narache: follow the arrow from NPC to NPC."] =
        "Todo empieza en el Campamento Narache: sigue la flecha de PNJ en PNJ.",
})

end
_load('WTFDudeSuite',_WTF)
