# Preloaded gathering locations · 0.15.2

## Corrected data coverage

Earlier Durotar coordinates came from an incomplete quest-object sample: 18 Peacebloom positions and no Silverleaf positions. Gathering history was optional, but the missing preloaded positions made Herbalism look dependent on personal discoveries. The database now includes 16,292 positions across 40 map areas and 37 resource types. This includes 12,002 fuller Classic gathering-reference positions, replacing incomplete samples when available.

Durotar now has 82 Silverleaf positions, 93 Peacebloom positions, 54 Earthroot positions and 162 Copper positions in the raw catalogue. 21 Silverleaf/Peacebloom locations and 21 Copper locations fall inside the broad Valley of Trials region (35–53 x, 58–86 y); this box includes nearby surroundings, not only the named subzone. Display/routing merges same-resource locations within 15 yards. No saved observations or gathering-data addon installation/import is required.

## Behavior

- Herbalism and Mining start at the closest eligible preloaded location, then visit the nearest remaining route stop. Crossing optimization no longer changes that nearest-neighbor order.
- Arriving within 8 yards advances to the next possible position even without harvesting or a loot event. Routes are search circuits, not a claim that every position currently contains a resource.
- Skill 1 Herbalism shows Silverleaf and Peacebloom; Earthroot is added at skill 15. Resource bands follow actual profession skill.
- Known node circles remain available while questing, for the selected learned gathering profession. The existing node-display toggle controls them. The gathering guide must be selected to follow its automatic circuit.
- World-map/guide-preview rendering can show up to 600 circles instead of dropping everything after 120. Minimap circles remain restricted to visible positions, capped at 120.
- A harvest near a known position marks its history without moving that known coordinate to the player's standing position.
- The floating overlay remains removed. Quest guide progress and personal gathering history are preserved.

## Source review and boundaries

Reviewed Gatherer's minimap-node implementation at [Hisha/Gatherer](https://github.com/Hisha/Gatherer/blob/main/Gatherer/GatherMiniNotes.lua), the original prefilled database approach at [Gatherer DB WoWHead](https://github.com/lloydpick/gathererdb_wowhead), and the [Gatherer-Elysium database](https://github.com/Grymskvll/Gatherer-Elysium). No Gatherer program code or private-server spawn tables are bundled.

The added coordinate facts come from [E1ila/GatherMate2_Data](https://github.com/E1ila/GatherMate2_Data), a Classic data reference based on Spinx GatherMate2 Data Classic / WoWHead. Resource IDs are mapped by name against [GatherMate2 constants](https://github.com/Nevcairiel/GatherMate2/blob/master/Constants.lua). Only coordinate/resource facts for compatible Classic zone IDs are compiled; addon logic, artwork, prose and external addon dependencies are not imported. Native Forever data retains priority for each resource/map pair. Classic data is withheld on known changed map frames (Mulgore, Redridge, Eastern Plaguelands, Stormwind); those areas still rely on native compatible positions and player observations. Classic positions remain references where Forever beta spawn tables have changed.

## Validation

Lua 5.1 mocked-client tests cover a fresh Orc Herbalist in Valley of Trials with empty history and recording disabled: preloaded Silverleaf/Peacebloom, nearby minimap circles, more than 120 world-map circles, closest first waypoint, nearest-neighbor order, six successive empty spots advancing without gathering, Earthroot unlocking at 15, full Copper data and passive circles while questing. Existing gathering recording/projection, all profession rank/cap, settings, Skyborne pickup and smart quest routing checks pass. Live terrain and server spawn alignment have not been visually verified on every Forever map; use Find Herbs / Find Minerals for live presence.
