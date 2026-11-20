# Third-party notices · 0.17.0

Dude, Where’s My Ding! includes the complete runtime, user interface, guides, translations and UI media of **Ding! v1.8.1**, by **moust4ki**, from the user-supplied `Ding-v1.8.1-forever.zip` (SHA-256 `d9707c45f42dc95429129e4f476e07d37ee90d6e07e6e84256b390ef685285ea`). Original project: https://www.curseforge.com/wow/addons/ding-xp-and-leveling-guide . This is an adapted integration, not an official Ding release or an endorsement by its author.

Ding declares GPL-3.0. Full license copies are provided in LICENSE, Licenses/Ding-GPL-3.0.txt and Native/LICENSE. The combined addon is distributed with its editable sources under GPL-3.0. Native/ retains original module, guide, locale and media organization. Changes isolate its namespace, saved variables, bindings and named frames, update media paths/title, share the already included base database, and integrate our tools through Core/NativeBridge.lua. Native/PORT-MANIFEST.json maps the supplied files and shared base database sources.

DB/Ding contains the generated QuestieDB v1.0.6 game data. Original Questie, QuestieDB, Ding corrections and cMaNGOS credits remain in Licenses/Ding-DB-CREDITS.md and Native/DB/CREDITS.md. Native database translations extend this shared table. Original guide-generation/authorship comments remain in guide files.

Noto Sans font files are included with their **SIL Open Font License 1.1** at Native/Media/Fonts/OFL.txt. Original controller/UI textures are retained under Ding’s distribution license. Blizzard game names/assets and previously attributed artwork retain their own ownership and terms; see SOURCES.md and prior gathering provenance notes.

## Integrated approaching-object sparkles

`Core/SoftTargetSparkles.lua` is adapted from the user-supplied Forever Loot Sparkles v1.3.0 `SoftTarget.lua`, by Ashtar Senior, itself adapted from the same author’s Lueur. Licensed GPL-3.0-or-later, as stated in the supplied addon manifest; the GNU GPL v3 text is included in LICENSE. Modified 2026-10-22 for private Dude, Where’s My Ding! settings/lifecycle, safe CVar access, built-in glint texture fallback and combat suppression. Original explanatory source comments are retained. No separate upstream settings category, saved-variable global or icon is installed. The quest-loot controller uses the same documented CVar behavior with a new native options integration.

### Sparkle artwork and recovery update (0.19.2)

`Media/SparkleFlare.tga` is the unmodified `Textures/flare.tga` from the user-supplied Forever Loot Sparkles v1.3.0 archive, bundled under its GPL-3.0-or-later package notice. Core/SoftTargetSparkles.lua additionally changes initial plate acquisition, external CVar recovery, recycled-nameplate resolution and resource classification when cursor metadata is absent. Original range, animation and state parameters are retained. All-category defaults are enabled once at user request; subsequent option edits are preserved.


## Transport route data · 0.20.0

DB/TransportPaths.lua adapts DockWatch 1.5.0's DockWatchPaths.lua under the MIT License, Copyright (c) 2026 Wyveryx. Full notice: Licenses/DockWatch-MIT.txt. Source package: https://www.curseforge.com/wow/addons/dockwatch/files/9489681 . Changes isolate the namespace as HP.TransportData. Recorded paths and durations are used by our independently written Core/TravelClock.lua; upstream old departure seeds are never read as live schedules. DockWatch's UI, communications and integrations are not loaded, and DockWatch is not required. Public project descriptions from other leveling/timer addons were reviewed for behavior; no proprietary guide content or InFlight code was imported.


## Group mark behavior review · 0.21.0

AutoMarkAssist v3.6.3 (Swatto, All Rights Reserved) was inspected for behavior and Forever limitations. None of its code, database or media is redistributed here. Core/GroupMarks.lua is independently written; it uses Blizzard's documented secure raidtarget action and our existing native configuration widgets. Sources and validation limits are listed in AUDIT-0.21.0.md.


## Spam-filter behavior review · 0.22.0

CrossIgnore, Sift, Forever Chat Filter and BadBoy project information was reviewed for feature comparisons. No code, media or filter corpus from these All Rights Reserved projects is distributed. Core/SpamFilter.lua and Core/SpamSettings.lua are independently written under this package's license. Primary API/project references are listed in AUDIT-0.22.0.md.

## Travel display comparison · 0.24.0

ForeverFlightPath and InFlight were reviewed as behavioral/design references. No code, media, fonts or flight-time databases from either are bundled by this change. Core/TravelDisplay.lua is independently written. It uses the existing WoW client assets at runtime. Existing DockWatch route-data attribution remains unchanged. Source links and validation are listed in AUDIT-0.24.0.md.
