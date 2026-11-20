# Live gathering audit · 0.18.0

## Implementation

Core/LiveGathering.lua adds a seventh native settings tab, Herbalism/Mining guide entry points, live detection/sound/detour toggles, profession filters and sound presets/preview. Settings width increases slightly to accommodate seven tabs. Existing scrollbar and picker fixes are retained.

Live detection is independently implemented using Forever Minimap:SetUsingSoftCursor, Minimap:UpdateMouseoverAtPoint and C_TooltipInfo.GetMinimapMouseover. Resource names match our existing facts and native localized object names. Only learned, skill-eligible professions and active tracking are considered. Scanning is batched (48 probes / 1 ms per frame), pauses in combat/instances/death/minimap use, restores cursor state after failures and backs off after client errors. No tracking spells or CVars are changed automatically.

Minimap sample positions are converted back through rotation and the map’s world-coordinate basis. Nearby same-type samples are grouped. Alerts are deduplicated by location, with a global cooldown. The two short profession cues are original PCM WAV assets, reproducible from Tools/GenerateGatherChimes.py. Game-sound presets remain available.

Detours integrate with native nearest-point selection and the existing trail. They do not change/confirm quest steps. Explicit manual/clicked destinations retain priority. Harvest, disappearance, filter/enable changes and skip restore normal navigation. Harvest suppression survives skill-event-before-loot ordering during the session. Historical node data and its visit rules are unchanged.

## Validation

- Simulated native minimap dots: Silverleaf detected; Copper ignored without Mining; Earthroot ignored below skill requirement; similarly named creature ignored.
- Actual probe batches remained within the 48-call cap and restored soft-cursor mode. Screen-to-map projection and rotated minimap conversion checked.
- Repeated detections suppressed duplicate audio; sound and redirect settings functioned independently. Profession-specific sound assets/preset preview and mute checked.
- Arrow/trail selected the live node without advancing a quest; node disappearance and successful gathering restored quest and profession routes. Manual destinations retained priority.
- Feature off, combat and minimap-use guards prevented probing. API exceptions cleaned up cursor state and triggered backoff. Unsupported clients showed an unavailable status rather than historical-node alerts.
- All seven native settings tabs, native option callbacks, prior scrolling/dragging/blinking fixes, original 221 guides / 13,216 steps and race/class gates passed existing mocked-client tests.
- Existing profession skill-band/material audit and historical gathering/visited-node regressions passed.

Live minimap observations remain estimates. Small dots, nearby clusters, movement, client changes and localization can affect detection/position precision. The feature has not been validated in a live WoW session by the agent. Existing saved progress is retained; no WTF files are edited during installation.
