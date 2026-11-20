# Audit · Dude, Where’s My Ding! 0.20.0

Date: 2026-11-07. Release target: live `_forever_`, Interface 16001. Before this update both inspected installations and workspace TOC reported 0.19.2. Source and live install backed up under work/backups before edits. No character SavedVariables/WTF file is edited by this release.

## Defects corrected

- Engine.Start restored saved low-level sections without reconsidering their level range. QuestReconcile now imports positive completion history and checks compatibility/range at startup and after a level change. The new Check now button does the same manually without deleting manual marks.
- A quest step combining a completed quest and an old travel point could remain pending. Only confirmed turn-ins can resolve this; independent trainer/hearth/flight/goals remain checked.
- A successful modern completion call returning nil suppressed the legacy completion API. Nil now falls through.
- Portrait placement was fixed to the left. Placement now follows the free side of the tracker with effective UI scales and updates while dragging.
- Transport countdowns were missing despite the route planner's existing flight-time collection. New local tracker clocks observe taxi selection, actual taxi state, recorded boat paths and user-confirmed dock events.

## Verification

`work/test_release020.py` runs the full existing suite plus targeted new tests. All passed with no captured lifecycle event errors.

- 2,119 Lua files compile with Lua 5.1.
- 221 guides / 13,216 steps remain registered; the existing 90 race/class/faction compatibility cases pass.
- An additional 90 level-22 compatibility selections all escape a level-1 starter into a compatible section covering level 22.
- Positive bulk quest history, active repeatable protection, completed-travel resolution, trainer protection, manual mark retention, disabled catchup, explicit browsing and nonleveling books.
- Modern nil completion flag -> legacy positive fallback.
- Portrait changes side at both screen edges with differing effective scales and the two-return GetCenter API.
- Thirteen boat/zeppelin connections; nearest dock detection; observed arrival/departure; missed-departure next-arrival countdown; clock expiry; per-instance path projection; four consistent onboard movement samples; stationary dock rejection; overlapping reverse tracks.
- Known flight countdown, first unknown flight learning, landing cleanup and flight-master name fallback.
- Travel settings page builds; route entries have the text/value fields required by the real dropdown widget.
- Existing settings/dropdown lifetime, scrollbar, movable arrow/directory, minimap trail, live gathering sound/detour, class-restricted gear, announcements, sparkle artwork and CVar recovery regressions remain passing.

These are client API simulations and syntax checks, not a live in-game playthrough. See FOREVER-LIVE-REVIEW-0.20.0.md for sources and outstanding data-validation limits.
