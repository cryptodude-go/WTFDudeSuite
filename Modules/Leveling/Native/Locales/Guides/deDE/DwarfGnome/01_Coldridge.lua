local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "deDE" then return end -- Skip inactive-language allocations.
-- German text of Guides/DwarfGnome/01_Coldridge.lua: [English text] = German text.
-- Written by tools/translate_guides.lua from tools/routes/locales/deDE.lua.
Ding.RegisterGuideTranslation("deDE", "dwarf-01-coldridge", {
    ["Coldridge Valley (1-5)"] =
        "Eisklammtal (1-5)",
    ["Everything starts in Coldridge: follow the arrow from NPC to NPC."] =
        "Alles beginnt im Eisklammtal: Folge dem Pfeil von NSC zu NSC.",
})

end
_load('WTFDudeSuite',_WTF)
