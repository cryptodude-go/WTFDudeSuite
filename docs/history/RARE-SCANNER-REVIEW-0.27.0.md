# RareScanner reference review · 0.27.0

Reviewed current Forever release RareScanner_FOREVER_1.60.1.3, CurseForge file 9493291, uploaded 7 November 2026.
https://www.curseforge.com/wow/addons/rarescanner/files/9493291

The reference has separate vignette, nameplate/target, soft interaction, class/race tracking, internal NPC/container/loot data, map/explorer, alert/model and navigation services. Vignette events expose nearby minimap sightings; the non-vignette path checks actual creature identity/death and known database membership, rejecting misleading pet-name matches. Its alert uses creature display IDs for NPC 3D previews, hiding the model for containers. It also offers curated spawn/loot maps, filtering and respawn telemetry. Those data/services are not all reproduced by this release.

Our integration is independently implemented inside Dude, Where’s My Ding!, using public game APIs and the addon's already present NPC rank database. No RareScanner Lua, database, images, sound or libraries are bundled and no dependency is added. This release focuses on live rare/treasure alerts, 3D where supported, own-loot previews, native settings and explicitly chosen quest-safe waypoint/line detours. It does not claim every rare has a vignette or that distant/cached spawn points prove a live rare is present.

Primary API reference:
https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/VignetteInfoDocumentation.lua
https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/MapDocumentation.lua

Reference archive SHA-256: 07557bfea575acc9cc2da720f3c9bb9b74e32533547b1f59f2012424cf474967
