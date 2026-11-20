local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/37_Stranglethorn.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-37-stv", {
    ["Stranglethorn Vale (37-39)"] =
        "Schlingendorntal (37-39)",
    ["Stranglethorn Vale is south of Duskwood: Rebel Camp in the north, Booty Bay in the south."] =
        "Das Schlingendorntal liegt südlich des Dämmerwalds: Rebellenlager im Norden, Beutebucht im Süden.",
    ["Booty Bay"] =
        "Beutebucht",
    ["Finish the level on nearby monsters before moving on."] =
        "Beende die Stufe an nahen Monstern, bevor du weiterziehst.",
})

end
_load('WTFDudeSuite',_WTF)
