# Compact travel display audit · 0.24.0

Date: 2026-11-07. Target: `_forever_`, Interface 16001. Source/live v0.23.2 backed up before edits. No WTF or saved-character files are edited by the installer.

## Primary comparisons

- https://www.curseforge.com/wow/addons/foreverflightpath — reviewed its compact route timer, origin/destination, ETA, learning and separate speed-profile description. No code, data or media imported from this All Rights Reserved project.
- https://www.curseforge.com/wow/addons/inflight-taxi-timer — reviewed compact timer, count-up/countdown, unknown-route handling, reload persistence, preview and appearance controls.
- https://github.com/LudiusMaximus/InFlight and its InFlight.lua/Defaults.lua — reviewed the author's current implementation and the documented treatment of different game eras. This release independently implements its own presentation and flight-session persistence; no InFlight code, textures, fonts or flight-time database are copied. The project site's license label and repository license differ; no reliance on copying either was needed.

This task changes presentation and adds flight-session persistence. It does not claim to implement every feature of either comparison addon: no guild sync, group chat announcements, wholesale default route DB, automatic speed-perk normalization or InFlight/Edit Mode dependency is added. Existing local measurement and transport observation logic remains the timing source.

## Implementation

Core/TravelClock.lua now exposes structured DisplayState for flight, transport ride, unsynchronized dock, waiting and boarding. It retains its text API for compatibility but no longer inserts a row into the quest tracker or refreshes that tracker every second. CaptureFlight stores the departure name alongside destination. Hiding timers controls display, while flight measurement remains active.

Core/TravelDisplay.lua is a separate nonsecure movable frame. Header shows transport/origin; destination, large clock, caption and ETA/detail have independent fixed-width regions. Default 360x66; width 280–480; scale 70–150%; background opacity 20–100%; Classic/Minimal styles; progress optional; count-up optional for rides/flights; per-character position, locking, reset and 30-second preview. The existing settings page uses native rows/sliders and does not refresh while a dropdown is open. Right-click opens that page. The display uses existing Blizzard icons/status-bar textures and a static spark at the fill boundary. A failed icon assignment falls back to the map icon. Faction controls flight/ride color; dock waiting/boarding have distinct status colors. Layout/backdrop are cached and the 0.1-second render does not rebuild them or resize/refresh the guide. No animated flashing or fake unknown-route percentage.

A persisted active-flight snapshot uses the current character's existing saved database and a client/server wall-clock epoch. On an on-taxi reload, only snapshots aged 0–3600 seconds are restored; fresh pending selections take priority. Flight time is restored as full elapsed time and learned once at landing, not as a partial remainder. The snapshot clears at landing. Without a clock, no cross-reload duration is invented. Boat schedules retain their old layer/age invalidation instead of persisting stale epochs.

## Validation

work/test_travel024.py runs the complete existing release chain, including quest/zone and combat/reset marking checks. New cases cover known flight destination/origin, countdown/ETA/progress, Horde/Alliance colors, count-up, unknown timing, overdue estimate, zero tracker refreshes and one backdrop layout over twenty render ticks, reload restoration/full single landing record, stale snapshot rejection, hidden-display learning, boat/zeppelin state, observed/missed/stale dock timing, dock toggle, draggable saved position, lock, style/scale/text-only changes, preview while disabled, preview expiry, immediate off switch and native settings controls. All Lua sources compile under Lua 5.1.

Mocked-client checks cannot establish live client font rasterization, server travel timings or every flight-master variant. Existing route measurements may become inaccurate after speed changes or server route changes; the UI labels them as estimates, retains elapsed/overrun feedback and continues learning. New Forever routes without measurements show elapsed time. A real Forever flight/boat playthrough remains useful to confirm appearance and runtime observations.
