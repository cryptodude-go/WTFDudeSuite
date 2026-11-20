local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/50_SearingGorge.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-50-searinggorge", {
    ["Searing Gorge (48)"] =
        "Sengende Schlucht (48)",
    ["Searing Gorge is south of Loch Modan, through the Badlands."] =
        "Die Sengende Schlucht liegt südlich von Loch Modan, über das Ödland.",
    ["If the starting item dropped: use it from your bags."] =
        "Startgegenstand erbeutet? Benutze ihn aus deinen Taschen.",
})

end
_load('WTFDudeSuite',_WTF)
