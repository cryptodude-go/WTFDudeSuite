# Audit · 0.17.0

The v0.16 adaptation transferred guide data but omitted native runtime features and replaced the settings design. This release incorporates the complete original implementation rather than recreating a subset of its switches.

## Implementation comparison

All original Core and UI modules are included under Native/, along with original guide/localization files, fonts and textures. The original settings builders retain all six tabs and all option rows. The tested native window contains 55 checkbox/selector/slider/dropdown/binding controls and the original theme/arrow cards. All 34 native checkbox callbacks were toggled both ways and restored in the mock runtime. Our extra pages use UI.CheckRow, DropdownRow and other original widgets.

Original guides register against an isolated namespace. The six large base database modules are reused from DB/Ding, avoiding duplicate allocations and duplicated archive data. Binding action names, saved-variable names, globals, named frames and media paths are adapted. Original source `/ding` and `_G.Ding` are not claimed. Setup, gamepad focus, travel, services, quests/offers, equipment, rewards, merchant, training, talents, goals, reports, import/export and localization modules are loaded in the original order.

Core/NativeBridge.lua hides the old tracker/settings/arrow, disables duplicate legacy quest automation, connects profession/reputation rows and recipe hover details to the native tracker, and feeds minimap lines from the native arrow’s actual destination. Gathering arrival checks retain their own route progression and do not advance a quest step. Native automatic quest advancement pauses while an auxiliary book is active. Existing legacy data is not overwritten; authored-step migration is per character.

The native guide interface replaces the old planner/Classic-only mode selector as the default quest interface. Its original Leveling, Zones, Class, Dungeon and Items books are available instead. Previous planner code and saved data remain preserved; its old UI is not displayed.

## Validation

- Every TOC Lua module loaded under Lua 5.1 in a mocked Forever client; native ADDON_LOADED and PLAYER_LOGIN lifecycle completed without recorded errors.
- Native Skyborne first-login guide selection produced a waypoint before quest acceptance.
- All 221 guides / 13,216 original steps retained; every authored next-guide link resolved.
- Guide/step eligibility evaluated for 90 race/faction/class combinations, including both Skyborne sides; compatible guides available. This checks filters, not whether every race/class combination is playable in the game.
- All six native settings tabs and both additional pages built; 55 native controls refreshed and 34 checkbox setters restored both states.
- Profession/reputation switching used the native tracker, kept legacy frames hidden and did not advance native quest progress.
- Native gathering Next advanced past the current site, and its arrow agreed with our route destination.
- Leatherworking 74/300 progress and recipe/material hover integration checked in the native panel.
- Retained profession audit exercised all 12 professions through skill 1–300, 150 bands, training caps, material estimates, live API overrides and recipe tooltips.
- Retained gathering regression checked preloaded Valley of Trials herbs, no-history routing, harvested/recent-site exclusions, expiration/reload behavior, recording off, Mining isolation, minimap rotation/zoom and projection.
- Retained library regression covered all original instructions, prerequisite recovery, faction/class gates, original source ordering and minimap route projection.

These are automated source and mocked-client checks. The interface has not been visually signed off in the live WoW client, and every beta quest, transport passage and protected action has not been played through. Beta data may change after the supplied export.
