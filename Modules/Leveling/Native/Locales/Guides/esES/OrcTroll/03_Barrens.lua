local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/OrcTroll/03_Barrens.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "orc-03-barrens", {
    ["The Barrens (11-19)"] =
        "Los Baldíos (11-19)",
    ["Cross the bridge west of Razor Hill into the Barrens, then follow the road to the Crossroads: your base."] =
        "Cruza el puente al oeste de Cerrotajo para entrar en Los Baldíos y sigue el camino hasta El Cruce: tu base.",
    ["The Crossroads"] =
        "El Cruce",
    ["Sun Rock Retreat"] =
        "Refugio Roca del Sol",
    ["Orgrimmar"] =
        "Orgrimmar",
})

end
_load('WTFDudeSuite',_WTF)
