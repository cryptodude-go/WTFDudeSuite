# WTF! DUDE SUITE

**Version 1.8 · World of Warcraft: Forever · Interface 16001**

A modular companion for leveling, questing, professions, gathering, navigation and group play. One addon folder contains the complete suite, with an overall switch and separate module switches in Settings.

This is a cumulative summary of features added from the first 0.x releases through version 1.8. It describes the current feature set and omits repair notes.

## Leveling and quest guides

- Compact, movable quest tracker with a race portrait, character level, current instructions, objectives and progress.
- Automatic race, class, faction and level detection, with saved progress for each character.
- A library of 221 guide sections containing 13,216 authored steps, covering leveling, starter zones, classes, dungeons and item guides.
- Alliance and Horde guides, including Skyborne starts and Forever quest data.
- Guide and zone selection, prerequisite tracking, quest-chain progression and class-specific steps.
- Nearby objective batching and route selection before returning for quest turn-ins.
- Upcoming-step previews, objective hover details, clickable destinations and optional guide explanations.
- Completed-quest reconciliation, guide resumption, previous/next controls, skipping and pause.
- Route preferences for hearthstones, optional death skips, elite/dungeon quests, trainers, flight paths and vendors.
- Nearby objectives, persistent instructions and quest-log cleanup suggestions.
- Guide import/export and a report-text creator for describing guide problems.

## Navigation and NPC directory

- Independent waypoint arrow with distance, estimated walking time and selectable arrow styles.
- World-map pins, minimap targets and dotted route lines.
- Manual waypoints using coordinates, map IDs, named zones and custom labels.
- Nearby NPC directory for vendors, repairs, food, reagents, inns, banks, flight masters and trainers.
- Travel guidance using walking passages, flight paths, boats, zeppelins and hearthstones when data is available.
- Movable arrow and directory windows with saved positions and scale controls.

## Professions and reputation

- Skill-based guides for Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring, Cooking, First Aid, Fishing, Herbalism and Mining.
- Rogue Lockpicking guides with practice areas, skill tiers and zone selection.
- Recipe hover information, estimated crafting quantities and approximate reagent requirements.
- Live skill/cap tracking, trainer milestones and optional profession instructions while leveling.
- Reputation guidebooks with faction selection and progression steps.
- Profession information on herb, ore and skinnable-creature tooltips, including current/required skill and difficulty colors.

## Gathering and chest circles

- A built-in database of 16,292 herb/ore reference positions across 40 map areas.
- An additional 277 fishing pool reference positions across 17 zones.
- Simultaneous circles for learned Herbalism, Mining and Fishing, including all resource tiers for the selected professions.
- Separate switches for world-map circles, minimap circles, herbs, ore, fishing, reference data and unlearned professions.
- Resource circles remain available while the leveling guide is closed or paused.
- Lime herb circles, gold ore circles, blue fishing circles and green personal harvest history.
- Click-to-waypoint navigation from resource circles.
- Skill-based herb/ore circuits, nearest unchecked destinations and recently checked/harvested location history.
- Per-character gathering history, including recognized fishing-pool loot sources.
- Known footlocker positions, skill colors, opened-chest history and a manual chest-position marker for Lockpicking.

Reference circles mark possible spawn locations. Exact availability depends on the server. Fishing loot without a recognized pool source is treated as an ordinary catch.

## Quest automation and gear

- Optional quest acceptance, turn-ins and reward selection.
- NPC quest-offer explanations and gray-quest preferences.
- Gear upgrade suggestions with class, level, armor, weapon and item-requirement checks.
- Weighted gear scores, upgrade percentages and comparisons with equipped items.
- Class leveling, melee, ranged, caster, healer and tank scoring profiles, with editable weights.
- Optional score/upgrade indicators in supported tooltips, bags, loot windows and quest rewards.
- **GREEDY AS FUCK** reward mode highlights the choice with the highest total vendor value, including reward quantity.
- Reward recommendation banner and an indicator around the recommended reward.
- Optional gray-item selling, merchant repairs and equipment assistance.

Automatic reward selection requires both the reward-selection and automatic turn-in options. The normal reward policy prioritizes suitable upgrades.

## Sparkles

- Quest-item sparkle controls.
- Approaching-object sparkles for herbs, ore and optional quest objects.
- Nearby lootable-corpse sparkle support.
- Separate category checkboxes and restoration after supported graphics-setting changes.

## Group marks

- Party and raid marking controls with location and group-authority preferences.
- One-key marking, including supported combat key/button actions.
- Sequential kill/CC marker planning with icon reservation and existing-marker awareness.
- Caster/danger priorities and optional group-class crowd-control preferences.
- Dead/stale target handling, pack reset controls and Clear all.
- Dedicated direct-marker bindings and configurable controls.

Combat marking uses the supported player key/button actions.

## Ignore and spam filter

- Gold-seller/spam filtering for supported whispers and chat channels.
- Built-in rules, editable custom word/phrase filters and channel switches.
- Automatic-ignore or hide-only behavior.
- Ignore history with timestamps, list management and removal controls.
- Exceptions for trusted players, friends and group members.

## Rare scanner

- Rare/rare-elite detection from readable nearby units and supported minimap vignettes.
- Optional treasure, event and personal rare-loot alerts.
- Movable alert window with the selected suite skin.
- 3D NPC or item/character preview when supported, with icon fallback.
- Sound controls, alert browsing, per-entry ignore and explicit waypoint navigation.
- Sightings history, duplicate suppression and alert cooldowns.

## Travel timers

- Flight countdowns for measured routes and elapsed timers for unknown routes.
- Learning from completed flights, with route context and destination information.
- Flight-master previews and route tooltips.
- Boat and zeppelin travel displays and observed next-arrival estimates.
- Compact/detailed timer styles, selected suite skin and saved window placement.

Boat/zeppelin arrival estimates require an observed or synchronized schedule.

## Chat, statistics and PvP sound

- Party/raid announcements for completed quest objectives and level-ups.
- Ten editable quest messages and ten editable level messages.
- Random message selection, repeat avoidance and message placeholders.
- Separate channel switches and level/quest announcement deduplication.
- Character activity summaries, session/day totals and progression statistics.
- An original pistol sound for confirmed personal or pet PvP killing blows.
- Killing-blow sound switch and preview button.

Kill sounds require a readable player-kill event from the game.

## Interface and module controls

- One **WTF! DUDE SUITE** entry in the game's AddOns list.
- Thirteen Settings tabs with the module rail on the left.
- Overall suite switch and individual switches for each feature module.
- Native-style buttons, yellow checkmarks, dropdowns and visible scrolling.
- Selectable skins, opacity, scale, combat display preferences and saved window positions.
- Keyboard, mouse, keybinding and supported controller navigation.
- Localized interface/guide resources with English fallback.
- Installed version displayed on the right side of the Settings footer.
- Optional new-version notifications from other suite users in the group or guild.
- A version-information popup with a copyable GitHub link and one notification per newer version.
- On-demand memory/CPU snapshots through Settings or `/wtf performance`.
- Throttled map updates, bounded caches and suspended inactive drivers.

## Install

Place the complete `WTFDudeSuite` folder directly inside your WoW Forever `Interface/AddOns` directory. The file `WTFDudeSuite.toc` belongs directly inside that folder. Fully restart WoW, enable **WTF! DUDE SUITE**, then open Settings with `/wtf`.

```text
Interface/
  AddOns/
    WTFDudeSuite/
      WTFDudeSuite.toc
      Core/
      DB/
      UI/
      Native/
      Media/
      Modules/
        Leveling/
        Professions/
        Reputation/
        Gathering/
        Navigation/
        AutoQuests/
        Sparkles/
        GroupMarks/
        Ignore/
        RareScanner/
        Travel/
        Community/
      README.md
      LICENSE
```

All module files ship inside this folder. Use their Settings switches to enable or disable their behavior. Their code and shared data load with the suite.

### Upgrade from the earlier multi-folder release

Exit WoW before migrating. Account and character saves from `DudeWheresMyDing.lua` can be copied to `WTFDudeSuite.lua` in the same `WTF/Account/.../SavedVariables` directories. The compatible saved-variable contents are retained. Existing `WTFDudeSuite.lua` saves should be preserved when already present.

Replace the previous Core and twelve `WTFDude_*` addon folders with the single `WTFDudeSuite` folder. Keep one installed copy of the suite.

## Commands

| Command | Action |
| --- | --- |
| `/wtf` or `/dudesuite` | Open suite Settings |
| `/dwmd` | Toggle the guide |
| `/wtf performance` | Print a performance snapshot |
| `/wtf gear` | Open gear scoring options |
| `/way 40.6, 52.4` | Set a waypoint in your current zone |
| `/way Loch Modan 49.4 12.9 Loch Modan Dam` | Set a named waypoint in another zone |
| `/wtf way 1432 49.4 12.9 Loch Modan Dam` | Set a waypoint using a map ID |
| `/wtf clearway` | Clear the manual waypoint and resume guide navigation |

Use `/wtf way` when another installed addon owns the shorter `/way` command.

## Visual Studio and GitHub

Open the installed `Interface/AddOns/WTFDudeSuite` directory as the folder workspace in Visual Studio. Use that folder as the repository root so `WTFDudeSuite.toc`, `README.md` and `Modules` are directly at the root.

Editing Lua files in this folder edits the installed addon. Use `/reload` to load saved code changes. Restart WoW after adding files or changing the file layout. The included `.gitignore` excludes Visual Studio local metadata. GitHub releases should package the repository inside one top-level `WTFDudeSuite` directory.

## Version notifications and GitHub

Open **Suite options → New version notifications** to control automatic notices. The version appears on the right side of the Settings footer. `/wtf updates` opens the version/GitHub window.

The in-game checker exchanges version numbers through WoW addon messages in your group or guild. When another suite user reports a higher version, the popup appears once for that version. Notifications wait until combat ends. Player-reported versions are identified as reports.

WoW addons cannot fetch GitHub pages directly. The optional `Tools/Check-GitHub.ps1` checks this public repository over HTTPS. It prefers the latest stable GitHub Release and falls back to the version in `main/WTFDudeSuite.toc` when needed. It writes validated version data to `Core/ReleaseInfo.lua`, which the addon reads at the next login or reload.

Run `Tools/Launch-WoW.ps1` from the installed addon folder to check GitHub before launching WoW. You can also run the checker on its own and then use `/reload`. These scripts check version metadata and prepare the notice. Install a downloaded release to update the addon files.

To publish a new version, update `## Version:` in `WTFDudeSuite.toc`, commit and push your changes, and preferably publish a GitHub Release with a matching numeric tag such as `v1.8` or `v1.8.1`. Package the release with the single `WTFDudeSuite` top-level folder. Keep the default empty `Core/ReleaseInfo.lua` in published source.

## License and credits

Distributed under GPL-3.0. See `LICENSE` and `Licenses/` for retained third-party notices, guide/database credits and source details.

The feature set is checked with Lua 5.1 and simulated game events. Live game behavior depends on the APIs and data exposed by the current Forever client.
