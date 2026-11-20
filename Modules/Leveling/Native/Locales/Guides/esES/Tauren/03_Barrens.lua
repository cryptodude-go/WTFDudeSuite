local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Tauren/03_Barrens.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "tauren-03-barrens", {
    ["The Barrens (12-19)"] =
        "Los Baldíos (12-19)",
    ["Leave Mulgore by the road east into the Barrens, then north to the Crossroads: your base."] =
        "Sal de Mulgore por el camino del este hacia Los Baldíos y sube al norte hasta El Cruce: tu base.",
    ["The Crossroads"] =
        "El Cruce",
    ["Camp Taurajo"] =
        "Campamento Taurajo",
})

end
_load('WTFDudeSuite',_WTF)
