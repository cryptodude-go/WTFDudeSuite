local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Undead/02_Tirisfal.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "undead-02-tirisfal", {
    ["Tirisfal Glades (6-13)"] =
        "Tirisfal (6-13)",
    ["Leave Deathknell by the road east to Brill: your base for Tirisfal Glades."] =
        "Verlasse Todesend über die Straße nach Osten bis Brill: deine Basis für Tirisfal.",
    ["Brill"] =
        "Brill",
    ["If the starting item dropped: use it from your bags."] =
        "Startgegenstand erbeutet? Benutze ihn aus deinen Taschen.",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
})

end
_load('WTFDudeSuite',_WTF)
