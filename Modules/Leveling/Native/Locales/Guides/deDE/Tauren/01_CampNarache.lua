local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Tauren/01_CampNarache.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "tauren-01-narache", {
    ["Camp Narache (1-5)"] =
        "Camp Narache (1-5)",
    ["Everything starts at Camp Narache: follow the arrow from NPC to NPC."] =
        "Alles beginnt im Camp Narache: Folge dem Pfeil von NSC zu NSC.",
})

end
_load('WTFDudeSuite',_WTF)
