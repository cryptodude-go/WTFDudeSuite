local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
-- Adapted for DudeWheresMyDing 0.16.0; original guide by moust4ki / Ding v1.8.1, GPL-3.0.
-- Runtime registration is private; original guide content and attribution are retained.
local _, HP = ...
local Ding = HP.DingGuideAdapter
-- Drafted by tools/draft_guide.lua from tools/routes/alliance.lua and the QuestieDB
-- Forever export, then checked with tools/check_guides.lua. Edit the route, not this file:
-- it is written again on each run. Quest ids only, names and places come from QuestieDB.
-- French text: Ding/Locales/Guides/frFR/Alliance/50_BlastedLands.lua.
-- Simulated: level 48 (97%) -> 49 (17%), 3 quests turned in, about 1 h 01 (24 927 XP per hour).
Ding.RegisterGuide({
    id       = "alliance-50-blastedlands",
    pack     = "ding-zones",
    title    = "Blasted Lands (48-49)",
    faction  = "Alliance",
    minLevel = 48, maxLevel = 49,
    next     = "alliance-51-ungoro",
    steps    = {
        { turnin = 2990, -- level 48
          note = "Fly to the Blasted Lands, south of the Swamp of Sorrows: the Alliance keep in the north of the zone is your base." },
        { accept = { 2601, 2603 } }, -- level 48
        { complete = { 2603, 2601 } }, -- level 48
        { turnin = { 2601, 2603 } }, -- level 49
    },
})

end
_load('WTFDudeSuite',_WTF)
