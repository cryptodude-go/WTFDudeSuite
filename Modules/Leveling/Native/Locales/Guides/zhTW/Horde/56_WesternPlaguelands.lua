local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
local _, HP = ...
local Ding = HP.Native
if Ding.locale ~= "zhTW" then return end -- Skip inactive-language allocations.
-- Traditional Chinese text of Guides/Horde/56_WesternPlaguelands.lua: [English text] = Traditional Chinese text.
-- Written by tools/translate_guides.lua from tools/routes/locales/zhTW.lua.
Ding.RegisterGuideTranslation("zhTW", "horde-56-wpl", {
    ["Western Plaguelands (53-55)"] =
        "西瘟疫之地 (53-55)",
    ["The Western Plaguelands are east of Tirisfal Glades: the Bulwark guards the border, east of Brill."] =
        "西瘟疫之地位於提里斯法林地東邊：亡靈壁壘守衛著布瑞爾東邊的邊界。",
    ["Finish the level on nearby monsters before moving on."] =
        "先在附近打怪升完這一級再繼續。",
})

end
_load('WTFDudeSuite',_WTF)
