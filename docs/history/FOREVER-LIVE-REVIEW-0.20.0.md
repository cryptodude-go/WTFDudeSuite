# Forever live addon review · 2026-11-07

Review scope: official project pages, author documentation and available source. This is a comparison of currently discoverable projects, not a claim that every published addon was downloaded, installed or played through. Forever is treated as a released game; beta-only claims on old pages are historical. The current library remains 221 registered guides / 13,216 steps. It has not been replaced with another vendor's content.

| Project / primary source | Relevant behavior / decision |
| --- | --- |
| [Ding!](https://www.curseforge.com/wow/addons/ding-xp-and-leveling-guide) | Supplied v1.8.1 remains the licensed baseline. Its saved-section loading path lacked an outleveled-section recheck. We added that independently. |
| [Questie](https://www.curseforge.com/wow/addons/questie) | Current Forever flavor; quest-state-driven assistance. Positive completion flags/history are the authority in our reconciliation. No wholesale database replacement performed. |
| [Guidelime](https://www.curseforge.com/wow/addons/guidelime) | Automatic guide progression; reinforces keeping manual navigation distinct from completion. Public behavior reviewed, proprietary content not copied. |
| [RestedXP](https://www.curseforge.com/wow/addons/restedxp-guide) | Current Forever distribution and guided leveling. No paid routes or engine code imported. |
| [Zygor Forever release history](https://www.zygorguides.com/archive/?package=ZygorGuidesViewerForever) and [controls](https://content.zygorguides.com/support/manual/controls) | Released Forever package; next-incomplete-step navigation is a useful UX reference. No guide content copied. |
| [PexGuide](https://pexguide.com/en/) | Author advertises all starting races including Skyborne; compare faction/race filtering and newcomer progression. |
| [ForeverWisp](https://www.curseforge.com/wow/addons/foreverwisp) | Starter-route/gathering scope is narrower than a full 1–60 quest library. Retain our separate profession/reputation books. |
| [FlowUp](https://www.curseforge.com/wow/addons/flowup-forever) | Another current Forever guide project; inspected advertised scope, no code imported. |
| [WoW-Pro](https://www.curseforge.com/wow/addons/wow-pro) | Current community guides with a noncommercial content license. Route content was not merged into our GPL guide library. |
| [Journey](https://getjourney.gg/support) | Dedicated Forever support and guide coverage; public support information inspected. No subscription content imported. |
| [ForeverGuide](https://github.com/prezus/ForeverGuide) | Resynchronization/outleveled quest handling are relevant design references. Older beta labels are not used as evidence about today's game. |
| [InFlight](https://www.curseforge.com/wow/addons/inflight-taxi-timer) | Learning actual flight durations is appropriate when a reliable schedule is unavailable. All-rights-reserved implementation was not copied. |
| [DockWatch](https://www.curseforge.com/wow/addons/dockwatch) | v1.5.0 source inspected. MIT route geometry and measured durations reused with attribution; local clock/UI are our implementation. |
| [Azeroth Tripview](https://www.curseforge.com/wow/addons/tripview) | Player-observed transport synchronization is relevant. No synchronization network, UI or external dependency imported. |

## Applied changes

1. A manual, nondestructive quest-history check and automatic catchup beyond the active section's maximum level. Race/class/faction filters are retained; required chain prerequisites can remain older than the player.
2. Completed quest travel coordinates cannot keep a step pending when all its quest actions are turned in and other goals are satisfied.
3. Manual step browsing, an explicit off switch, and nonleveling books remain respected.
4. Flight measurements use both legacy and modern taxi selection hooks, with name-based fallback for flight masters missing from the old NPC database.
5. Boat/zeppelin ETA uses recorded geometry plus a recent observation. A stationary player beside a path cannot calibrate a clock; both directions are tested independently where recorded tracks overlap.

API reference: [Forever quest-log API documentation](https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua), particularly GetAllCompletedQuestIDs. The fallback still checks individual completion flags and actual recorded turn-ins if the bulk history API is unavailable.

## Limits requiring live validation

A source review and mocked-client tests cannot verify every live server quest coordinate, prerequisite change, ship timetable, or layer. No claim of flawless 1–60 playthrough is made. Existing guide/data provenance is retained. Required old chain quests are not indiscriminately removed. Transport durations are estimates, and old departure epochs are never trusted as live phase. A first unknown flight is measured rather than shown with a fabricated ETA. If you missed an unobserved transport, mark an observed arrival/departure before expecting its next visit countdown.
