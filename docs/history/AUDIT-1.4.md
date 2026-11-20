# Performance audit · 1.4

15 November 2026. Baseline: verified v1.3 source/release; rollback ZIP retained. No features or guide data removed. Internal addon/save names stay compatible.

The update reduces recurring work and allocation churn. It does not turn a multi-module guide/data suite into a single-purpose addon or implement load-on-demand database modules. The full quest/guide database is still loaded at login.

## Controlled scheduling comparison

600 simulated frames at 60 FPS (10 seconds), same six driver callbacks, with expensive target functions replaced by counters. This measures scheduled calls, not milliseconds of actual work, real CPU percentage, FPS or live client memory. Disabled-driver callbacks are deliberately invoked in this benchmark to compare the internal throttles; real hidden drivers do not receive OnUpdate.

| Work | v1.3 calls | v1.4 calls |
|---|---:|---:|
| lines | 85 | 85 |
| chests | 600 | 99 |
| gear | 13 | 0 |
| live | 600 | 19 |
| gather | 600 | 99 |
| travel | 85 | 39 |

Stable settings pages: 40 close/reopen cycles per page after initial construction, no additional frame/texture/font objects in the simulated UI. Dynamic pages retain their rebuild behavior; this is not a claim that every settings list is pooled. The eight-entry node cache discards lookup references only; current route/display references remain valid.

Inactive guide translations exit before table construction; all 1,547 files also execute correctly with their intended active locale. Existing localized DB/UI guards were already present and retained. Cold-load emulation showed approximately the same retained Lua memory (~115 MiB) before and after this work; no overall RAM reduction percentage is claimed. The improvements target runtime allocation, unbounded page revisits and optional background work. Live game totals can differ.

Live detector retains max 48 probes and max 1 ms per batch, now at most 40 Hz. It remains bounded independently of FPS, pauses for combat, preserves cursor cleanup/backoff, alerts during partial sweeps, and restores quest routing after harvesting/disappearance. The same-size/shape grid is reused; node-name lookup changes when learned profession toggles, localized resolver, language or data backend change. Scan completion on very high-FPS clients may take longer because work is intentionally capped.

Timer display cadence is separate from movement/arrival and learning state; hiding a display never suppresses landing recognition or timing measurements. This follows the same separation highlighted by TomTom’s changelog: https://www.curseforge.com/wow/addons/tomtom/files/8560433 (distance callbacks independent of minimap visibility; skip unnecessary hidden waypoint computations). No external code copied.

Optional drivers are hidden when unused; a lightweight 1 Hz coordinator wakes them on state changes, and Suite/skill/world events reconcile immediately. Event handlers remain available while drivers sleep. No gathering sound/marking key/rare event or quest-completion callback is replaced by screen polling. Navigation and arrival callbacks remain independent.

Validation: historical navigation/dropdown/gathering/sparkle/gear/quest/marking/spam/travel/rare regression chain; v1.0 module/settings tests; v1.1 gear/travel/skin tests; v1.2 Lockpicking tests; v1.3 gathering tooltip tests; v1.4 scheduler, sleep/wake, cache bounds, settings reuse, gear invalidation, locale guards and demand-only diagnostics tests. Existing coverage: 221 guides, 13,216 steps, 90 race/class/faction combinations. Lua 5.1 compilation checked through the suite.

Testing uses simulated UI/game APIs. A live before/after RAM, CPU and FPS profile is still needed; no in-game benchmark was performed. Installation changes addon files only, never live WTF/SavedVariables.
