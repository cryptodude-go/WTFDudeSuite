local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/20_Redridge.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-20-redridge", {
    ["Redridge Mountains (18-19)"] =
        "Rotkammgebirge (18-19)",
    ["Redridge is east of Elwynn Forest: follow the road east to Lakeshire. Night Elves: boat from Auberdine to Menethil, Ironforge, then the tram to Stormwind."] =
        "Das Rotkammgebirge liegt östlich des Waldes von Elwynn: Folge der Straße nach Osten bis Seenhain. Nachtelfen: Schiff von Auberdine nach Menethil, Eisenschmiede, dann die Bahn nach Sturmwind.",
    ["Lakeshire"] =
        "Seenhain",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
})

end
_load('WTFDudeSuite',_WTF)
