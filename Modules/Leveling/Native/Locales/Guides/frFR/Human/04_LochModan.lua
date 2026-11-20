local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "frFR" then return end -- Skip inactive-language allocations.
-- French text of Guides/Human/04_LochModan.lua: [English text] = French text.
-- Written by tools/translate_guides.lua from tools/routes/locales/frFR.lua.
Ding.RegisterGuideTranslation("frFR", "human-04-lochmodan", {
    ["Loch Modan (16-18)"] =
        "Loch Modan (16-18)",
    ["Take the Deeprun Tram from Stormwind to Ironforge, then the road east through Dun Morogh to Thelsamar."] =
        "Prends le tram des profondeurs à Hurlevent jusqu'à Forgefer, puis la route de l'est par Dun Morogh jusqu'à Thelsamar.",
    ["Thelsamar"] =
        "Thelsamar",
})

end
_load('WTFDudeSuite',_WTF)
