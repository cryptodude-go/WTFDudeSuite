local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
-- Adapted for DudeWheresMyDing 0.16.0; original guide by moust4ki / Ding v1.8.1, GPL-3.0.
-- Runtime registration is private; original guide content and attribution are retained.
local _, HP = ...
local Ding = HP.DingGuideAdapter
-- Drafted by tools/draft_guide.lua from tools/routes/horde.lua and the QuestieDB
-- Forever export, then checked with tools/check_guides.lua. Edit the route, not this file:
-- it is written again on each run. Quest ids only, names and places come from QuestieDB.
-- French text: Ding/Locales/Guides/frFR/Horde/43_SwampOfSorrows.lua.
-- Simulated: level 42 (23%) -> 42 (65%), 6 quests turned in, about 1 h 35 (25 726 XP per hour).
Ding.RegisterGuide({
    id       = "horde-43-swamp",
    pack     = "ding-zones",
    title    = "Swamp of Sorrows (42)",
    faction  = "Horde",
    minLevel = 42, maxLevel = 42,
    next     = "horde-44-feralas",
    steps    = {
        { accept = 1393, -- level 42
          note = "The Swamp of Sorrows is east of Deadwind Pass: Stonard is your base." },
        { complete = 1393 }, -- level 42
        { turnin = 1393 }, -- level 42
        { accept = { 698, 1430 } }, -- level 42
        { sethearth = "Stonard" }, -- level 42
        { accept = 1424 }, -- level 42
        { complete = 698 }, -- level 42
        { complete = 1424 }, -- level 42
        { turnin = 698, accept = 699 }, -- level 42
        { complete = 1430 }, -- level 42
        { complete = 699 }, -- level 42
        { turnin = 699 }, -- level 42
        { hearth = true }, -- level 42
        { turnin = { 1430, 1420, 1424 } }, -- level 42
    },
})

end
_load('WTFDudeSuite',_WTF)
