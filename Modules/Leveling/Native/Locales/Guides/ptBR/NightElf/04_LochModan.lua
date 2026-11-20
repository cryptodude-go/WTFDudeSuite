local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "ptBR" then return end -- Skip inactive-language allocations.
-- Brazilian Portuguese text of Guides/NightElf/04_LochModan.lua: [English text] = Brazilian Portuguese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/ptBR.lua.
Ding.RegisterGuideTranslation("ptBR", "nightelf-04-lochmodan", {
    ["Loch Modan (19-21)"] =
        "Loch Modan (19-21)",
    ["Boat from Auberdine to Menethil Harbor, then the road east through the Wetlands to Loch Modan: Thelsamar is your base."] =
        "Barco de Auberdine para o Porto de Menethil, depois a estrada para o leste pelo Pantanal até Loch Modan: Thelsamar é sua base.",
    ["Thelsamar"] =
        "Thelsamar",
})

end
_load('WTFDudeSuite',_WTF)
