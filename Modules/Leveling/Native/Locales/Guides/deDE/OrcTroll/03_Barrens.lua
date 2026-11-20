local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/OrcTroll/03_Barrens.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "orc-03-barrens", {
    ["The Barrens (11-19)"] =
        "Brachland (11-19)",
    ["Cross the bridge west of Razor Hill into the Barrens, then follow the road to the Crossroads: your base."] =
        "Überquere die Brücke westlich vom Klingenhügel ins Brachland, dann folge der Straße zum Wegekreuz: deine Basis.",
    ["The Crossroads"] =
        "Das Wegekreuz",
    ["Sun Rock Retreat"] =
        "Sonnenfels",
    ["Orgrimmar"] =
        "Orgrimmar",
})

end
_load('WTFDudeSuite',_WTF)
