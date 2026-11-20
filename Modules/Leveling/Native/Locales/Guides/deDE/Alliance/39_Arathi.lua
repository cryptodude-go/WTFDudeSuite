local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/39_Arathi.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-39-arathi", {
    ["Arathi Highlands (39-40)"] =
        "Arathihochland (39-40)",
    ["The Arathi Highlands are north of the Wetlands, across Thandol Span."] =
        "Das Arathihochland liegt nördlich des Sumpflands, hinter dem Thandolübergang.",
    ["If the starting item dropped: use it from your bags."] =
        "Startgegenstand erbeutet? Benutze ihn aus deinen Taschen.",
})

end
_load('WTFDudeSuite',_WTF)
