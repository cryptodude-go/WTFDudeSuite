local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Alliance/28_Stonetalon.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "alliance-28-stonetalon", {
    ["Stonetalon Mountains (27)"] =
        "Steinkrallengebirge (27)",
    ["The Stonetalon Mountains are west of Ashenvale."] =
        "Das Steinkrallengebirge liegt westlich des Eschentals.",
    ["Stonetalon Peak"] =
        "Steinkrallengipfel",
})

end
_load('WTFDudeSuite',_WTF)
