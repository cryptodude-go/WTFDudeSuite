local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "esES" then return end -- Skip inactive-language allocations.
-- Spanish text of Guides/Human/04_LochModan.lua: [English text] = Spanish text.
-- Written by tools/translate_guides.lua from tools/routes/locales/esES.lua.
Ding.RegisterGuideTranslation("esES", "human-04-lochmodan", {
    ["Loch Modan (16-18)"] =
        "Loch Modan (16-18)",
    ["Take the Deeprun Tram from Stormwind to Ironforge, then the road east through Dun Morogh to Thelsamar."] =
        "Toma el Tranvía Subterráneo de Ventormenta a Forjaz y luego el camino al este por Dun Morogh hasta Thelsamar.",
    ["Thelsamar"] =
        "Thelsamar",
})

end
_load('WTFDudeSuite',_WTF)
