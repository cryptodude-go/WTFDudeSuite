local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/39_Arathi.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-39-arathi", {
    ["Arathi Highlands (39-40)"] =
        "Hautes-terres d'Arathi (39-40)",
    ["The Arathi Highlands are north of the Wetlands, across Thandol Span."] =
        "Les Hautes-terres d'Arathi sont au nord des Paluns, par le gouffre de Thandol.",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
})

end
_load('WTFDudeSuite',_WTF)
