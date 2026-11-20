local _WTF=assert(_G.WTFDudeSuiteRuntime)
local function _load(...)
-- Adapted for DudeWheresMyDing 0.16.0; original guide by moust4ki / Ding v1.8.1, GPL-3.0.
-- Runtime registration is private; original guide content and attribution are retained.
local _, HP = ...
local Ding = HP.DingGuideAdapter
-- Drafted by tools/draft_guide.lua from tools/routes/alliance.lua and the QuestieDB
-- Forever export, then checked with tools/check_guides.lua. Edit the route, not this file:
-- it is written again on each run. Quest ids only, names and places come from QuestieDB.
-- French text: Ding/Locales/Guides/frFR/Alliance/43_Stranglethorn.lua.
-- Simulated: level 41 (33%) -> 41 (84%), 5 quests turned in, about 2 h 09 (22 945 XP per hour).
Ding.RegisterGuide({
    id       = "alliance-43-stv",
    pack     = "ding-zones",
    title    = "Stranglethorn Vale (41)",
    faction  = "Alliance",
    minLevel = 41, maxLevel = 41,
    next     = "alliance-45-tanaris",
    steps    = {
        { accept = 576, -- level 41
          note = "Back to Stranglethorn for the end of its quests, from Booty Bay." },
        { accept = { 617, 604, 209 } }, -- level 41
        { sethearth = "Booty Bay" }, -- level 41
        { complete = { 576, 604 } }, -- level 41
        { turnin = 576 }, -- level 41
        { complete = 617 }, -- level 41
        { accept = 196 }, -- level 41
        { complete = 196 }, -- level 41
        { complete = 209 }, -- level 41
        { turnin = 196 }, -- level 41
        { hearth = true }, -- level 41
        { turnin = { 209, 604, 617 } }, -- level 41
    },
})

end
_load('WTFDudeSuite',_WTF)
