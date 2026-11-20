# Dude, Where's My Ding? — 0.12.1 audit

Date: 19 October 2026. Scope: the standalone addon and every visible settings category. The guild addon is unchanged by this update.

## Findings corrected

| Finding | Correction |
| --- | --- |
| Profession percentage alternated with character XP | Both label and bar use the active guide's progress. Skill is explicitly shown against 300. |
| Training stops and completion could show 0% | Progress is calculated before early returns for training/unlearned/completed states. |
| Craft instructions lacked recipe/pattern and material budgets | Native hover tooltip, source, per-craft reagents, approximate remaining crafts, total materials, bag quantities and shortages. |
| Tools could be mistaken for consumed materials | Tools and reagents are separate factual fields. Enchanting rods are never budgeted per enchant. |
| Cooking included an absent Classic recipe and an unreachable final reference target | Replaced with Poached Sunscale Salmon for 250–275 and Lobster Stew for 275–300; verified recipe/material/vendor facts. |
| Higher-skill herbs/ore were listed too early | Current gather instructions filter individual resource requirements. Hover lists thresholds. |
| Fishing borrowed land farming loops | Uses shoreline spots; does not draw an herb/ore circuit as a fishing route. |
| Modern recipe APIs could hide working legacy data | Empty/filtered modern lists fall back to trade/craft APIs. Recipe links/IDs support localized names. |
| Secondary profession slots could be skipped | All six profession slots are checked, including nil primary slots. |
| Leveling navigation opened Chapters instead | Leveling has its own guidebook page. Chapters remains a separate browser. |
| Some settings had little visible effect in the compact layout | Extra explanations now control extra hover hints; XP ETA is shown on progress-bar hover. |
| Auxiliary modes retained quest behavior | Old quest arrival checks, target previews and nameplate highlights are isolated from auxiliary guides. |
| Deferred sizing and guide changes were inconsistent | Auxiliary rendering applies deferred size/scale. Last guide selection wins after combat. |
| Repeated profession events redrew unnecessarily | Events invalidate caches immediately and coalesce the visible update within 0.1 seconds. Open guidebook details update too. |
| Auxiliary slash commands could reset saved quest steps | `/sync` and `/reset` refresh the active auxiliary guide; guide/quests commands switch modes explicitly; manual waypoints and deferred scale work in auxiliary mode. |
| Alert sound choices could sound identical | Distinct raid-warning and ready-check choices, with visible names and previews. |

## Visible settings coverage

All 27 switches were invoked in both directions and checked against saved configuration. Other visible controls were exercised as described below.

| Category | Coverage |
| --- | --- |
| Overview | Guidebook links and return to leveling. |
| Leveling | Dedicated page; Normal/Classic-only Speedrun; return/resume and chapter browser. |
| Professions | Twelve choices; profession-only selector; optional reminder during leveling; live rank/cap; recipe hover and material details; gathering preview. |
| Reputation | Fourteen faction choices; live rank/method; reputation-only selector; undiscovered/completed states. |
| Chapters / zones | Browser, search, details and explicit zone selection; saved leveling route retained while auxiliary guides run. |
| Guide mode | Normal/Speedrun switch resumes leveling; Forever additions excluded from speedrun candidates. |
| Navigation | Automatic waypoint, arrow visibility/lock/size and reset. |
| Map / gathering | Numbers, dotted routes, animation, minimap trail and circle style. Minimap gathering segments checked against circle bounds. |
| Display | NPC preview, fit-to-step, XP ETA, transparency, extra hover hints, completed steps, strike-through, guide size/reset, quest-item bar/reset. |
| Quest & target | Rescan, diagnostics, skull marking, visible-target alert/sound choice, class/Forever/group/raid filters. |
| Announcements | Separate party/raid toggles for quest completion and level gains, editable messages, Save, defaults, level-time tokens. Mock destinations checked without sending real chat. |
| Tracker / minimap | Pause/resume, close/show, minimap left/right clicks, top Settings and target position regressions. |

## Verification performed

- Full active TOC load and Lua 5.1 execution.
- Every rank 1–300 for every profession: 3,600 rank cases, all 150 contiguous bands, plus all three training caps for each profession.
- All 131 compiled recipe/component records checked for reagent IDs/counts and reference thresholds; selected crafting targets do not exceed their reference gray point.
- Reported percentage reproduction: character XP 24%, profession skill 12/300, repeated alternating panel/XP updates. Profession stays 4%; live skill 74 stays 24%.
- Recipe/pattern tooltips, declining remaining material budgets, bag shortages, current training limits and non-consumed tool separation.
- Modern and legacy API shapes, localized names and IDs, filtered/closed recipe windows, client reagent overrides and explicitly gray/unlearned recipes.
- Repeated frame reuse; 100-event bursts coalesce into one update; no extra frames across repeated refresh/hover cycles.
- Combat-deferred guide selection, quest-history isolation, cleanup of recipe metadata when returning to quest rows, and invalid selection recovery.
- Existing standalone navigation, red progress bar, target placement, quest reconciliation and one-time migration regressions retained.

## What these checks do not establish

These are automated checks in a mock client and an approximate visual render, not a complete live Forever playthrough. They cannot certify that an addon is flawless on every beta build. Native tooltip/map/combat behavior still needs in-game confirmation.

Craft counts are approximate, with a spare-material budget rather than a guaranteed maximum. Live recipe reagents take precedence when exposed by an open profession window. Static skill thresholds remain Classic references and can differ in Forever. Gathering corridors remain suggested routes, not live spawn locations or obstacle-aware paths. The previously documented 369 partially verified zone-quest records remain partial; this profession/options update does not claim new verified quest routes.
