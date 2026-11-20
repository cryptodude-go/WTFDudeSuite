local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Tauren/02_Mulgore.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "tauren-02-mulgore", {
    ["Mulgore (5-12)"] =
        "Mulgore (5-12)",
    ["Follow the road north out of Camp Narache to Bloodhoof Village: your base for Mulgore."] =
        "Folge der Straße vom Camp Narache nach Norden zum Dorf der Bluthufe: deine Basis für Mulgore.",
    ["Bloodhoof Village"] =
        "Dorf der Bluthufe",
})

end
_load('WTFDudeSuite',_WTF)
