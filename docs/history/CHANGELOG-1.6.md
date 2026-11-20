# WTF! DUDE SUITE 1.6

- Added 277 fishing pool reference positions in 17 zones, combining native Forever object locations with Classic GatherMate2_Data where native locations are missing.
- Added simultaneous herb, mining and fishing circles on the world map and minimap, independent of the guide window, pause state and selected skill band.
- Added per-profession, world-map, minimap, database and unlearned-profession checkboxes in Gathering. Existing per-character harvest history remains supported.
- Clicking a resource circle now uses the current manual waypoint arrow and minimap line. Fishing pool loot identified by GameObject GUID is recorded. Ordinary open-water catches do not create pool markers.
- Added GREEDY AS FUCK in Automation. The recommendation banner and reward ring identify the highest total vendor value, including reward quantities, while the normal upgrade-first policy stays available.
- Added an original pistol sound for confirmed personal/pet PvP killing blows, with an enabled-by-default checkbox and preview in Chat & statistics. Duplicate events are suppressed. Protected identities are skipped.
- Kept map processing at 10 Hz for nearby minimap circles, with an eight-entry per-zone cache and idle drivers when display options are disabled.
- Preserved manual /way coordinates, named zones and labels from 1.5.2.

Verification used Lua 5.1 and simulated events. Gameplay verification in the live client remains pending.
