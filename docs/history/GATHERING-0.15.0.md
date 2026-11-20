# Gathering maps and circuits — 0.15.0

## Use

Open Settings → Gathering, or type `/dudeding gather`. Choose Mining or Herbalism, leave Resource and Farm zone on Automatic, then select Start guide and show overlay. If the current zone has suitable known nodes or a recommended suggested circuit, the guide stays there. Otherwise it recommends another compatible zone.

The floating current-zone map has an on/off setting and a 20–100% terrain-opacity slider. Its text, circuit and current-target marker stay readable while the terrain becomes transparent. Drag the title bar to move it; its position and opacity save for the character. Use Show current-zone map while leveling for a companion map alongside questing. The map always shows the current zone, even when an explicit farm-zone choice is elsewhere.

Gold circles are reference locations, green circles are places you gathered yourself, and a blue numbered circle is the current gathering stop. Use the game's Find Minerals / Find Herbs tracking for live nodes. Reference and historical circles do not claim that a resource is currently spawned. Hover for the resource and required skill; clicking a circle sets a manual waypoint. Resume guide clears that manual target and rejoins the current guide. Previous/Next in the tracker still move between circuit stops.

## Routing

Mining and Herbalism use the actual live profession rank and training cap. Automatic resource bands follow the leveling guide. Higher-skill resources remain excluded until usable; the guide stops for training at the current cap. The target changes after skill gains. A manually selected resource returns to the skill guide once it is too low to provide further progress.

Known-node circuits start near the player, connect up to 32 nearby suitable positions, remove simple crossing segments with a bounded 2-opt pass, and close back onto the start. Nodes within a local cluster are used rather than sending a low-rank gatherer across an entire map to every known location. Arrow progression checks arrival twice per second while gathering: eight yards for indexed nodes, thirty for suggested corridor stops. It advances on arrival so an empty historical location does not lock the guide. Gathering itself remains manual.

There are 6,190 reference positions across 31 map areas and 37 resource targets, plus recognition of six Ooze Covered ore variants. Points combine our earlier factual object records with current native Forever object tooltips. Known altered Era map frames are withheld unless the resource's current Forever points are available. The Zephras reference includes 435 ore positions.

Where coordinates are not indexed, an existing independently authored surface circuit can be used in a guide-recommended zone. It is explicitly labeled Suggested circuit and does not create fake resource markers. Examples include some Herbalism routes and starter-zone gaps. New locally recorded positions become usable route data after enough distinct points are available. This is partial reference coverage, not every beta node or a benchmarked fastest route. Endgame Forever-only herbs/ore outside the Classic 1–300 catalogue are not included. Cave floors, terrain barriers and enemy danger still require player judgment; straight connecting segments are not a terrain pathfinder.

## Recording

Recording has its own green ON/OFF switch. Recognized game-object loot-source IDs establish harvested-node observations. On clients without source GUIDs, the fallback requires a successful Mining/Herbalism cast and matching loot; ambiguous ore variants are withheld unless identifiable. Failed casts, creature loot, ordinary bag changes, purchases and trades do not create nodes.

Observations are local to this character, stored with the existing addon progress. Nearby repeated taps merge; storage is bounded to 500 locations per map and 4,000 overall. No sharing, external upload, Gatherer installation or additional addon dependency is required. Historical circles remain visible for the selected profession even when an older resource is no longer a leveling target. Routing still uses the current eligible resource band.

## Guide and addon review

- [WoW-Professions Mining 1–300](https://www.wow-professions.com/classic/mining-leveling-guide-classic-wow): checked resource tiers and recommended zones. Automatic tiers use Copper, Tin/Silver, Iron/Gold, Mithril/Truesilver and Thorium progression.
- [WoW-Professions Herbalism 1–300](https://www.wow-professions.com/classic/herbalism-leveling-guide-classic-wow): checked skill bands and alternative farming zones. The current suitable zone takes priority over a fixed default destination.
- [Zockify Forever Mining](https://www.zockify.com/forever/professions/mining/) and [Forever Herbalism](https://www.zockify.com/forever/professions/herbalism/): reviewed beta profession changes. New endgame resources are not silently treated as Classic leveling nodes.
- [Native Copper Vein facts](https://nether.wowhead.com/forever/tooltip/object/1731) and [Silverleaf facts](https://nether.wowhead.com/forever/tooltip/object/1617): examples of the factual resource-name, skill-gate and exposed-coordinate refresh. Website map art is not bundled; the overlay uses native game map layers.
- [Gatherer source reference](https://github.com/jsb/Gatherer/blob/master/Gatherer.lua) and [GatherMate2 collector reference](https://github.com/Nevcairiel/GatherMate2/blob/master/Collector.lua): reviewed local observation, duplicate suppression, cast/loot correlation and map markers. The implementation is our own; neither addon nor its runtime/database is installed or bundled.

This was a review of relevant accessible guides, not a claim to have checked every website or validated a universal fastest route.

## Validation

Automated tests cover closed Mining and Herbalism circuits, nearest entry, walking advancement, skill gates, trainer caps, current-zone selection, explicit zones/resources, source-gap labels, loot-source recording, duplicate taps, failed casts, old-client fallback, recording toggle, green history circles, live selectors, opacity bounds, native terrain tile cropping/aspect, rendered line closure and minimap clipping. Sixty repeated map/page redraws reuse existing frames and controls. The existing Skyborne, quest-batching, profession and settings regressions pass as well.

Profession settings also remain open during auxiliary-guide refreshes; the previous unconditional menu-close behavior was removed. The options footer now reads the installed addon version.

These are source and logic tests, not a live WoW beta rendering or farming playthrough. Fully restart WoW after installing the new files.
