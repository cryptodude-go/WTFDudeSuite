# Coverage · 0.19.2

- Live gathering: dedicated tab, Herbalism/Mining guide entry points, profession/skill filtering, Forever minimap-dot scanning, opt-in sound alerts, original chimes, automatic arrow/line detours and route restoration. Requires active game tracking and supported client APIs. Saved spawn positions are never treated as live sightings.
- Full supplied Ding v1.8.1 runtime, six-tab settings window, original widgets/checkmarks, tracker/next-step previews, arrow, gamepad, travel, service finder, quest offers, merchant, gear/rewards, training/talent suggestions, timing/reporting and text guide import/export.
- 221 original sections: 86 leveling, 75 starter/zone, 18 class, 41 dungeon, one item guide; 13,216 authored steps. Original guide and step faction/race/class gates retained. Both original Skyborne faction routes included. These are the supplied guide contents, not a claim to contain every possible quest added after that dataset.
- Base reference database: 5,226 quests, 13,392 NPCs, 6,994 objects and 21,279 items. Shared in memory with the retained v0.16 adapter. Original locale modules and translated guides included.
- Our 12 profession guides, 131 recipe/material records, 14 reputation guides and optional profession reminders use the native tracker and native settings widgets. Craft quantities remain estimates; client recipe/material data takes priority when available.
- Gathering: 16,292 reference positions across 40 map areas / 37 resource types. Current-zone preference, skill gates, visit exclusions, historical nodes and route lines retained. No live spawn detection or terrain pathfinding is claimed. Floating overlay remains removed.
- Original automation and client-supported actions are available through real handlers, not placeholder switches. Initial migration leaves automatic quests, gray-item selling and repairs off. Existing saved choices thereafter are preserved.
- No live WTF edits. New native settings/progress are isolated from old progress and from another Ding addon. Original controller actions and named frames use unique identifiers.

Passed mocked Lua 5.1 tests do not replace in-game visual, combat-lockdown and full route playthrough checks. No claim of flawless support for unverified beta content is made. Historical v0.16/v0.15 audit files describe those versions, not current missing features.
