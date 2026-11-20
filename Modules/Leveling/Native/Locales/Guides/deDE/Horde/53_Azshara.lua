local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/Horde/53_Azshara.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "horde-53-azshara", {
    ["Azshara (51)"] =
        "Azshara (51)",
    ["Azshara is east of Ashenvale: Valormok, in the southwest of the zone, is your base."] =
        "Azshara liegt östlich des Eschentals: Valormok im Südwesten des Gebiets ist deine Basis.",
})

end
_load('WTFDudeSuite',_WTF)
