local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Undead/03_Silverpine.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "undead-03-silverpine", {
    ["Silverpine Forest (13-15)"] =
        "銀松森林 (13-15)",
    ["From Brill, take the road west then south over the bridge into Silverpine Forest: the Sepulcher is your base."] =
        "從布瑞爾沿道路往西，再往南過橋進入銀松森林：據點是瑟伯切爾。",
    ["The Sepulcher"] =
        "瑟伯切爾",
})

end
_load('WTFDudeSuite',_WTF)
