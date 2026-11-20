# Gathering route backtracking correction · 0.15.3

## Cause

A new herb/ore observation cleared the route cache and reset the active route. The previous route did not remember which sites had just been checked. Skill gains could rebuild the eligible-resource route again. Separately, minimap/world-map route rendering still drew the entire closed circuit, including completed spots and the final return edge. Existing tests covered initial nearest-neighbor order and empty arrivals, but did not cover successive harvests combined with catalogue/skill invalidation.

## Changes

- Recently checked sites are excluded for 3 minutes; successfully harvested sites for 10 minutes. These are retry policies, not claims about server respawn timers. The route chooses the nearest remaining eligible site.
- Visit information is saved per character, map and gathering profession. Recent existing harvest timestamps also exclude spots after a reload or update. Skill changes, catalogue rebuilds and manually rebuilding a circuit do not erase recent visits.
- Successful harvesting still suppresses immediate backtracking when historical node recording is disabled.
- Reaching an empty site consumes it once; the route replans from the current location instead of advancing an index into the old circuit. Same-profession reference positions within 20 yards share a checked-site exclusion, avoiding duplicate alternate-spawn positions.
- When every known eligible location in the selected zone was checked recently, the guide waits for a retry instead of immediately returning to a green historical circle. Minimap markers remain historical/possible positions and do not prove a live spawn.
- Lines show the player-to-next-stop path and remaining unchecked stops. Completed edges and the forced closing return segment are no longer shown. Suggested corridors for areas without indexed node positions retain their previous behavior.
- The next arrow skips the current gathering destination; the previous arrow explicitly reviews the last checked location as a manual waypoint. Manual destinations, pause and disabled automatic navigation remain respected.
- Herbalism and Mining keep independent visit records. The removed floating overlay remains removed; gathering observations and quest progress are preserved.

## Validation

Lua 5.1 mocked-client reproduction: harvest A, harvest B, gain skill, repeatedly invalidate/rebuild the catalogue, and verify the next target remains C. Check an empty C and continue to D; unlock Earthroot without revisiting alternate positions beside recently harvested spots; finish the route and verify a waiting state rather than an immediate return; advance time to verify retry behavior. Also covered persisted recent harvest history, recording OFF, remaining-line points, manual/pause/auto-waypoint controls, next/previous arrows and independent Mining visits.

The fresh Valley of Trials, node projection, harvesting events, profession skill/cap, settings, reputation, Skyborne pickup and smart quest routing regressions pass. Live game rendering and actual server spawn presence still require in-game verification.
