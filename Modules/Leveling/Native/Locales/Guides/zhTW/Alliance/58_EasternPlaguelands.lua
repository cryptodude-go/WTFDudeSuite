local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Alliance/58_EasternPlaguelands.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "alliance-58-epl", {
    ["Eastern Plaguelands (55-56)"] =
        "東瘟疫之地 (55-56)",
    ["The Eastern Plaguelands continue the Western ones to the east: Light's Hope Chapel is in the east."] =
        "東瘟疫之地緊接在西瘟疫之地東邊：聖光之願禮拜堂在東部。",
    ["Light's Hope Chapel"] =
        "聖光之願禮拜堂",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完這一級再繼續。",
})

end
_load('WTFDudeSuite',_WTF)
