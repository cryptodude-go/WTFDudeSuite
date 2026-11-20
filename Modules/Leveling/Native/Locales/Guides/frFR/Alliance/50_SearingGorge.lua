local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Alliance/50_SearingGorge.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "alliance-50-searinggorge", {
    ["Searing Gorge (48)"] =
        "Gorge des Vents brûlants (48)",
    ["Searing Gorge is south of Loch Modan, through the Badlands."] =
        "La Gorge des Vents brûlants est au sud de Loch Modan, par les Terres ingrates.",
    ["If the starting item dropped: use it from your bags."] =
        "Si l'objet de départ est tombé : utilise-le depuis ton sac.",
})

end
_load('WTFDudeSuite',_WTF)
