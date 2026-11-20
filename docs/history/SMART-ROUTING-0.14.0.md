# Smart quest batching — 0.14.0

The previous planner favored turn-ins and retained a manual quest focus after objectives completed. This could send the player back to a giver while accepted work remained nearby.

## Behavior

SmartRouting.lua now orders eligible quests by their current phase and projected travel distance in Normal and Speedrun guide modes. Existing class, level, faction, prerequisite, difficulty, skip and Speedrun quest-selection filters run first. The planner never adds a quest excluded by those filters.

- Complete nearby accepted objectives together before returning to a giver.
- Release a pinned objective when its phase changes to turn-in. Explicitly selecting a turn-in with the navigation arrows remains supported.
- Return first when the remaining objective is sufficiently far away, or the giver is already nearby.
- Pick up an available quest when already near its giver before leaving the hub.
- Batch ready turn-ins at nearby givers, then refresh eligibility so newly unlocked quests are considered.
- Preview queued objectives followed by a return hub on the world map and minimap. The trail follows planned order rather than quest-list indices, so an earlier-listed quest cannot disappear from the route preview.
- Preserve manual waypoint navigation, profession/reputation guide behavior, pause/hide switches and the existing route-line controls.

## Distance policy

Distances use native world projections in yards when available. Same-map dimensions are the fallback. Incomparable world instances and unknown locations are not treated as adjacent.

A ready giver within 65 yards is favored; available pickups within 60 yards can be collected before departure. Otherwise unfinished work is favored when its next objective is within the larger of 450 yards or 1.15 times the distance to the nearest ready return. This is a practical batching heuristic, not a globally optimal route. An unpinned current objective has an 80-yard stability margin to avoid switching between overlapping spawn areas during small movements.

Lookahead is bounded to eight actual stops, with a virtual return after planned objectives. Once a return hub is reached in the preview, the next field trip is planned from refreshed quest state. Up to six nearby ready turn-ins are grouped there. Objective completion and quest-log events trigger the existing refresh path; no extra polling timer is added.

The map/minimap trail uses native waypoint locations and known questgiver locations. It represents visit order using straight segments; terrain, roads, caves, water and enemy danger are not modeled as a pathfinding graph. Unknown locations use the existing fallback behavior rather than invented coordinates. Accepted native objective waypoints still take priority.

## Tests

Automated Lua tests verify the full production refresh/phase/waypoint pipeline with Harmony in Balance ready for turn-in and Infestation Investigation incomplete. The remaining mobs are selected first, then a giver is selected after both quests finish.

Additional scenarios cover three nearby quests, all-ready hub batching, distant objectives, givers already nearby, nearby pickups, unknown objective positions, different world instances, phase-changing manual focus, explicit manual turn-in selection, skipped quests, small-movement stability and meaningful distance improvements. Tests check planned point order, clipped minimap dots, reuse across 100 redraws, visibility/pause/manual controls, Speedrun eligibility and auxiliary-mode separation. The full existing quest, Skyborne, settings, profession and UI logic suites pass.

These are automated logic tests, not a native-client playthrough. The previous Skyborne source review and questgiver catalogue remain included.
