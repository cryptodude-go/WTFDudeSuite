# Sparkle parity and recovery audit · 0.19.2

Compared both Lua modules, settings/defaults, events and artwork with the supplied ForeverLootSparkles-v1.3.0-forever.zip. The integration already retained its corpse checks, cursor classification, quest-object detection, animation, state hysteresis, range/icon CVars, combat deferral and all-off restoration. The previous port substituted the flare texture and retained the source’s extra quest-object default OFF; the current character’s saved settings confirmed it was OFF. The separate addon was also installed and enabled, allowing competing CVar controllers.

Changes:
- Bundle the byte-identical source flare asset under our media folder and use it with the original fallback.
- Enable all five categories once per character for the explicitly requested all-on setup; subsequent changes persist.
- Request interaction nameplates before the first readable object rather than closing the gate when no target is exposed. Check actual gate CVar state instead of trusting a cached boolean.
- Resolve direct and recycled nameplate tokens; recognize world-object GUIDs where the object flag is not yet exposed. Known resource IDs/aliases and localized names can classify herbs/ore without mouse cursor metadata. Explicit quest cursors retain their classification.
- Repair externally reset interaction CVars and graphics/account-sync settings after a short delay. Ignore synchronous notifications from our own CVar writes. Defer repairs in combat, retain original settings restoration when disabled.
- Archive the duplicate standalone installation outside AddOns, without editing WTF or saved variables. A full game restart is required to rescan addon folders.

Validation: work/test_sparkles0192.py runs the full v0.19.1 regression chain (including class-restriction fixes) and new tests for no mouseover/cursor metadata, initial target acquisition, GUID/localized beta resource fallback, a CVar reset concealed by the prior cached flag, direct-to-nameplateN recycling, delayed interaction/account-sync recovery, combat deferral, once-only all-on defaults, user choice retention and all-off restoration. It checks source-event coverage and identical source range/animation/state parameters, plus exact flare bytes. Every Lua file compiles as Lua 5.1. Package/installed hashes verified separately. These are mocked-client tests; no live game scene was observed or controlled.

Limits retained from the supplied addon: the game’s quest-loot effect applies to eligible quest loot; approaching glints use the single selected soft interaction target at approximately 15 yards, rather than all objects throughout the zone.
