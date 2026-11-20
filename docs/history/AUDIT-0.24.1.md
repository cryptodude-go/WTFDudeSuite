# Quest pin lifecycle audit · 0.24.1

Date: 2026-11-07. Source/live v0.24.0 backed up before edits. Live target `_forever_`, Interface 16001. Installation edits addon files only, never WTF/SavedVariables.

## Findings

Arrow.Focus retained bare points until the entire guide/index changed, so a clicked objective remained pinned when another objective/quest still blocked the same step. Engine.pendingTargets returned all database targets when its pending list became empty, reviving completed spawns. Engine completion checks relied on the finished flag despite the panel already accepting fulfilled counters. MarkWorld returned early for a nil key after reload even when a saved owned waypoint existed. Its cache/ownership were also updated before API operations succeeded, losing retries on failure. UserWaypoint accepted only table position fields and treated unreadable data as no waypoint. TomTom cleanup discarded owned UIDs before calling removal, similarly losing retry capability.

## Changes

Focus receives row context from both mouse/focus selection and CycleTarget, including whether that quest was in the log. Core/QuestPins.lua invalidates focus per objective, acceptance, ready status, removal or actual turn-in. PointsOf refuses completed rows. Pure quest steps with finished actions no longer use their old go coordinate as a destination; unrelated training/service/goals remain governed by their own completion. The engine recognizes fulfilled counters and leaves pending targets empty when every mapped live objective is done. Missing/unmapped objective data is not invented as completion. Turn-in NPC pins remain valid until actual hand-in.

Quest lifecycle events refresh the current candidates and native pins/trail, with a signature that ignores unchanged/partial counters to avoid restarting loops on duplicate quest events. The ordinary engine update path remains authoritative for step advancement. A reconciliation error releases its busy flag so later events can recover. Auxiliary profession/reputation books are untouched; gathering detour wrappers and existing candidate routing remain intact. Native minimap pins hide when paused.

World pin cache settling occurs after valid API outcomes. A persisted owned pin is examined even when the in-memory key is nil after reload. Failed reads/set/clear retain ownership and use a 0.5-second retry; unknown read state does not authorize deleting a player waypoint. A different current player waypoint is preserved and our obsolete ownership forgotten. UserWaypoint supports table/userdata objects, field coordinates and GetXY fallback, retaining multi-return coordinates. Explicit false API results are refusals. Optional TomTom removal preserves only our exact UIDs until success; arrow cleanup backs off and failed removal prevents duplicate new waypoints. A failed replacement of an existing client-owned pin does not leak it into an unrelated TomTom fallback.

## Validation

work/test_pins0241.py runs the full prior regression chain, including combat/reset marks and the travel display, then tests native world waypoint removal, persisted nil-cache cleanup, preserving manual/replacement pins, failed set/clear/read retries, false API return handling, userdata/GetXY and direct-field-failure fallback, and exact TomTom UID cleanup/retry. A synthetic multi-objective/multi-quest guide exercises same-step focused objective completion, count-first status, sibling quest continuation, no revived spawns, completed-row clicks, duplicate-event stability, valid turn-in transition, actual hand-in focus release, completed-guide world/minimap/trail cleanup, pause with a manual waypoint, and error-lock recovery. All Lua files compile under Lua 5.1.

These are mocked-client/source checks rather than an in-game quest replay. A new pin may correctly replace an old one when another objective or turn-in is still required. Pins owned by the player or other addons are intentionally not bulk-deleted.
