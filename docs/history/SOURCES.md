# Sources and data status

The interface follows the user's screenshot and [Zygor's public viewer controls documentation](https://www.zygorguides.com/support/manual/controls). Code, branding, and route instructions are original.

Selected factual quest/entity records were checked against the user's Questie Classic dataset in J:\World of Warcraft\_anniversary_\Interface\AddOns\Questie\Database\Classic. Only selected IDs, names, requirements, prerequisites, item-source IDs, and representative coordinates are indexed. Quest descriptions and third-party route instructions are not imported.

Forever entries checked include:

- [Your Place in the World](https://www.wowhead.com/forever/quest=4641/your-place-in-the-world)
- [Cutting Teeth](https://www.wowhead.com/forever/quest=788/cutting-teeth)
- [Sting of the Scorpid](https://www.wowhead.com/forever/quest=789/sting-of-the-scorpid)
- [Sarkoth](https://www.wowhead.com/forever/quest=790/sarkoth)
- [Sarkoth follow-up](https://www.wowhead.com/forever/quest=804/sarkoth)
- [Simple Tablet](https://www.wowhead.com/forever/quest=3065/simple-tablet)
- [Vile Familiars](https://www.wowhead.com/forever/quest=792/vile-familiars)
- [Burning Blade Medallion](https://www.wowhead.com/forever/quest=794/burning-blade-medallion)
- [Galgar's Cactus Apple Surprise](https://www.wowhead.com/forever/quest=4402/galgars-cactus-apple-surprise)
- [Lazy Peons](https://www.wowhead.com/forever/quest=5441/lazy-peons)
- [Thazz'ril's Pick](https://www.wowhead.com/forever/quest=6394/thazzrils-pick)
- [Report to Sen'jin Village](https://www.wowhead.com/forever/quest=805/report-to-senjin-village)
- [The Hunt Begins](https://www.wowhead.com/forever/quest=747/the-hunt-begins)
- [Rite of Strength](https://www.wowhead.com/forever/quest=757/rite-of-strength)
- [Rude Awakening](https://www.wowhead.com/forever/quest=363/rude-awakening)
- [Vital Intelligence](https://www.wowhead.com/forever/quest=383/vital-intelligence)

Other records, including Orc Warrior Simple Parchment (2383), come from the installed Classic index and are not labeled independently verified Forever records. Blizzard's generated API documentation was consulted through the [UI-source mirror](https://github.com/Gethe/wow-ui-source/blob/beta/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua).

Coordinates, availability, and pacing need a play-through in the actual beta build. Existing Classic IDs do not mean all Forever content is unchanged.


## Navigation and viewer reference (0.3.0)

- https://www.zygorguides.com/support/manual/waypoint — automatically selected step coordinates, clickable coordinate destinations, and a distance arrow. Our UI and Lua implementation are original.
- https://github.com/Nevcairiel/HereBeDragons — reviewed native coordinate conventions and minimap scaling; no library code is bundled.
- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/MapDocumentation.lua — Blizzard map API definitions.
- Selected NPC and object spawn-coordinate facts are retained from the installed Classic Questie data to show approximate objective areas. These remain unverified on Forever beta.

## Viewer refinement (0.3.1)

All 40 linked manual topics were reviewed for design context; the companion Leveling-guide-manual-review.md records implemented features and pending systems. Relevant references: https://zygorguides.com/support/manual/overview , https://zygorguides.com/support/manual/controls , https://zygorguides.com/support/manual/waypoint , and https://zygorguides.com/support/manual/action-buttons .

Questie’s README documents TomTom integration for objective arrows: https://github.com/Questie/Questie/blob/master/README.md . The new beveled arrow artwork is original. No TomTom or Zygor artwork/code is bundled.

TomTom integration: inspected local v4.2.4 README Supported Addon API, TomTom.lua and TomTom_CrazyArrow.lua. Project page: https://www.curseforge.com/wow/addons/tomtom . TomTom remains a separate addon with its original assets and license.

TomTom integration: inspected local v4.2.4 README Supported Addon API, TomTom.lua and TomTom_CrazyArrow.lua. Project page: https://www.curseforge.com/wow/addons/tomtom . TomTom remains a separate addon with its original assets and license.

Version 0.5.0 replaces TomTom integration with independently authored Lua navigation, an original 64-direction shaded arrow atlas and a separate guide/options panel. Zygor Home, Controls, Waypoint and Travel manual pages were reviewed again for interaction references. No Zygor source, artwork or guide text was copied.

Quest-item action-bar behavior references: https://zygorguides.com/support/manual/action-buttons . Original Lua implementation uses WoW SecureActionButtonTemplate item attributes; no Zygor macros or source copied.

## 0.6.0 factual expansion

- Classic factual quest/NPC/item/object index extracted from the locally installed Questie Classic database. No addon implementation or narrative objective prose was copied. Coordinates remain Classic references, not verified Forever positions.
- New quest IDs, names, levels and source links from the installed WoWForeverJournal catalog snapshot (September 2026). Faction filtering is conservative, based on Horde reputation entries; neutral additions without those entries may be absent.
- Individual new quest checks: https://www.wowhead.com/forever/quest=97279/wayward-weapons , https://www.wowhead.com/forever/quest=96822/for-honor , https://www.wowhead.com/forever/quest=96873/a-pain-in-the-neck , https://www.wowhead.com/forever/quest=96875/beasts-of-thunder-ridge , https://www.wowhead.com/forever/quest=97282/stormy-potential , https://www.wowhead.com/forever/quest=99142/tomb-weed , https://www.wowhead.com/forever/quest=99079/longwalker-malah . Checked 2026-10-11; missing navigation is explicitly marked.
- General zone progression reference: https://www.wowhead.com/classic/guide/horde-leveling-classic-wow . Our planner and zone descriptions are original; no proprietary leveling route or guide prose is copied.

## 0.7.0 design and quest checks (2026-10-11)

- Gallery reference: https://www.curseforge.com/wow/addons/joanasguides/gallery . Original card renderer, target controls and tooltip implementation; no addon source or artwork copied.
- Public starting guides reviewed: https://www.joanasworld.com/horde-1-12-durotar.php , https://www.joanasworld.com/horde-1-12-mulgore.php , https://www.joanasworld.com/horde-1-12-tirisfal-glades.php . No narrative or speedrun instructions incorporated.
- Attempted 12–60 guide pages: https://www.joanasworld.com/classic/horde-12-20.php , https://www.joanasworld.com/classic/horde-20-30.php , https://www.joanasworld.com/classic/horde-30-40.php , https://www.joanasworld.com/classic/horde-40-50.php , https://www.joanasworld.com/classic/horde-50-60.php . All redirected to membership login; linked fragment instructions unavailable. Chapter names/level brackets were provided directly by the user; generated quest planning is original.
- Wowhead Forever rechecks: quest 97279 links item 277653 and NPC 3159; quest 99142 links item 286204 and NPC 10665; quest 97282 links item 277665, NPC 3293 and preceding quest 97281. Individual quest/entity pages were inspected. No drop locations inferred from those links.

## 0.8.0 Camp Narache checks

Wowhead Forever pages checked 2026-10-11: https://www.wowhead.com/forever/npc=2980/grull-hawkwind , https://www.wowhead.com/forever/npc=2981/chief-hawkwind , https://www.wowhead.com/forever/npc=2991/greatmother-hawkwind , https://www.wowhead.com/forever/quest=747/the-hunt-begins , https://www.wowhead.com/forever/quest=750/the-hunt-continues , https://www.wowhead.com/forever/quest=752/a-humble-task . Quest/NPC identities are confirmed; exact numeric beta coordinates remain unverified. No retail Camp Narache coordinates were substituted.

Secure raid-target action reference: https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua . Original marking logic, with protected-call and combat guards; no third-party targeting implementation copied.


## 0.9.0 travel and protected-action research

- [Mythic Dungeon Tools](https://github.com/Nnoggie/MythicDungeonTools): project describes mapped dungeon route planning. Its README does not establish a bypass for beta protected raid marking. All raid marking was removed here.
- [FlightTimerClassic](https://github.com/timohausmann/FlightTimerClassic): records flight durations; consulted as a feature reference. Our flight-learning implementation is original.
- [NauticusClassic](https://github.com/psynct/NauticusClassic): describes observation-dependent boat/zeppelin schedules. Our original timer uses manual dock observations and does not send addon communications or preload its data.


## 0.9.2 map trail references

- [Zygor waypoint manual](https://zygorguides.com/support/manual/waypoint) and [Travel System](https://forum.zygorguides.com/support/manual/travel): coordinate navigation and separate travel routing; consulted for behavior. Our trails do not implement Zygor's travel network.
- [RestedXP map module](https://github.com/RestedXP/RXPGuides/blob/main/map.lua): dedicated map implementation reference. RouteTrail.lua is original code, with no guide prose or proprietary route data copied.


## 0.9.3 click marking

[Blizzard forum macro example](https://us.forums.blizzard.com/en/wow/t/macro-that-marks-your-target-with-the-skull-icon/1233335) and [WoW UI secure button source](https://github.com/tekkub/wow-ui-source/blob/live/FrameXML/SecureTemplates.lua) consulted for target-marker command and secure macro-button execution. No protected API bypass is used.


## 0.9.5 Forever factual snapshot and research

- [Wowhead Forever quests](https://www.wowhead.com/forever/quests): fetched zone quest tables and 260 individual new Horde/shared quest pages. Imported factual quest IDs/names, level/race/class/faction requirements, XP, mapped NPC/object coordinates and objective entity IDs. Did not copy guide prose, narratives or paid routes. Raw research files stay in work/, outside the release.
- [Zephras Isle zone overview](https://www.wowhead.com/forever/guide/zephras-isle-zone-overview): confirms the Skyborne 1–12 starter zone and class/faction context.
- [Zygor manual](https://zygorguides.com/support/manual/home): viewer, quest progression and navigation feature reference; Forever guides are listed as upcoming.
- [RestedXP Forever products](https://shop.restedxp.com/product-tag/world-of-warcraft-forever/) and [map source](https://github.com/RestedXP/RXPGuides/blob/main/map.lua): feature/compatibility reference; no premium guide text or routes imported.
- [Joana's official site](https://www.joanasworld.com/): current Classic guide compatibility and announcement that Forever-optimized guides will follow. No proprietary guide implementation copied.

0.9.8 quest-status and cleanup reference: https://github.com/RestedXP/RXPGuides/blob/main/QuestLog.lua and https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua. Our cleanup is manual instructions only; later chapter quests and unknown beta quests are retained.

0.9.9 refresh (2026-10-11): all 33 existing zone quest-list URLs plus Zephras Isle https://www.wowhead.com/forever/zone=16593/zephras-isle; 332 relevant quest pages. Vile Familiars: https://www.wowhead.com/forever/quest=792/vile-familiars. Public starter linked quest IDs: https://www.joanasworld.com/horde-1-12-durotar.php, https://www.joanasworld.com/horde-1-12-mulgore.php, https://www.joanasworld.com/horde-1-12-tirisfal-glades.php. Requested classic level 12–60 pages required login; detailed routes not accessible.

0.9.11 API event reference: https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua (HearthstoneBound). Travel suggestions are independently implemented against observed bind coordinates and item cooldowns.

0.10.0 reward UI API reference: https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestInfo.lua. Base money reward fields are factual values from the cached zone listings. Loot-source contract checked against the original developer example at https://www.wowinterface.com/forums/showthread.php?page=12&t=43091. No complete or guaranteed NPC loot table is claimed.


## Standalone 0.12.0 research · 19 October 2026

Quest ID/name/level/class/faction/reward and start/end coordinate facts: WCLBox public client snapshot, build 1.60.1.70450. Public UI: https://wowforever.wclbox.com/en/renwu ; factual resources used by that UI: /shuju/en/renwu/list.json and /shuju/en/renwu/q/{id}.json. 4,995 scoped records and 517 detailed records were imported without quest narrative, objectives prose, dialogue or editorial guide text. Name-changed Forever records replace incompatible older data instead of keeping an old NPC mapping. Existing Classic/Forever facts and their earlier attributions remain above.

Profession factual recipe/skill targets and trainer/book references were cross-checked against the author's guides at https://www.wow-professions.com/classic and its alchemy, blacksmithing, enchanting, engineering, leatherworking, tailoring, cooking, first-aid, herbalism, mining, skinning and fishing leveling-guide pages. No recipe counts or guide prose are reproduced. Live skill and exposed recipe information determine progress and materials; price and speed claims are not imported.

Reputation methods were checked against https://www.icy-veins.com/wow-classic/reputation-guides and its Argent Dawn, Timbermaw Hold, Thorium Brotherhood, Hydraxian Waterlords and Defilers reputation guides, plus https://www.wowhead.com/classic/guide/cenarion-circle-reputation-wow-classic and the Classic PvP faction overview. Instructions are original concise summaries of game mechanics. All new gathering polylines are original suggested corridors, not copies of the sources' maps.


## Profession recipe and options audit — 0.12.1, 19 October 2026

Current reference guides were checked at https://www.wow-professions.com/classic, including the eight crafting guides and Herbalism, Mining, Skinning and Fishing. Their descriptions, instructions and shopping lists are not reproduced. The guidebooks remain independently written skill-band instructions using factual recipe data.

131 selected crafting recipes/components and 208 item names are stored in ProfessionRecipes.lua. Consumed reagents and non-consumed tools were checked against individual current Classic spell tooltips, such as https://nether.wowhead.com/classic/tooltip/spell/3756 and https://nether.wowhead.com/classic/tooltip/spell/25127. Classic DB profession lists supply yellow/green/gray reference thresholds and output IDs: https://classicdb.ch/?spells=11.165 (Leatherworking); 11.171 (Alchemy), 11.164 (Blacksmithing), 11.202 (Engineering), 11.197 (Tailoring), 11.333 (Enchanting), 9.185 (Cooking), 9.129 (First Aid).

Lobster Stew recipe, skill requirement, reagent facts and vendor list: https://www.wowhead.com/classic/item=13947/recipe-lobster-stew and https://classicdb.ch/?item=13947. The Horde vendor is Sheendra Tallgrass in Feralas.

Craft budgets are an addon estimate, not a copied website shopping list. For each remaining skill point, a reference chance is approximated as 1 before yellow, otherwise (gray − skill)/(gray − yellow). The expected number of crafts is rounded up; an upper budget adds 20% when non-guaranteed skill gains are involved. The calculation stops at the current live training cap. Actual RNG and beta thresholds can differ, so the budget is explicitly approximate. Live profession reagent records override fallback reagents; a live trivial/gray recipe is blocked. Native recipe/pattern links display the client's own tooltip. No external guide narrative is included in the addon.


## Forever review 0.13.0 (2026-10-20)

See FOREVER-REVIEW-0.13.0.md for the native quest/NPC sources, secondary index, public addon comparisons, licensing boundaries and unresolved beta verification. Native names and matching independently compiled prior factual records override translated secondary labels; visual website chains do not automatically unlock quests.


## Skyborne pickup correction 0.13.1

See SKYBORNE-REVIEW-0.13.1.md and SKYBORNE-QUESTGIVERS.csv for the questgiver/chain review, native positions, factual cross-checks, race assumptions and automated pre-acceptance waypoint tests.


## Gathering update 0.15.0

GATHERING-0.15.0.md lists the Mining/Herbalism guide review, native object endpoints, Gatherer/GatherMate collector references, independent routing/recording implementation and partial node-coverage limits. Reference art is provided by native game map layers. No website map images or external gathering addon are bundled.


## Preloaded gathering correction 0.15.2

See GATHERING-0.15.2.md for Gatherer/GatherMate review, full Classic coordinate facts, source precedence, compatible map restrictions and fresh Orc/Valley of Trials tests. The database includes known positions before any harvest.


## Ding archive integration 0.16.0 — 22 October 2026

The user-provided Ding-v1.8.1-forever.zip is the source for adapted English guide definitions and its GPL-3.0 QuestieDB v1.0.6 export. See THIRD-PARTY-NOTICES.md, Licenses/Ding-DB-CREDITS.md and DING-REVIEW-0.16.0.md for attribution, source precedence, full module comparison and runtime limitations. No separate Ding dependency, fonts, theme assets or translation packs are included.

## Live gathering API research · 0.18.0

The detector is independently written. Forever minimap soft-cursor/tooltip API availability was verified against the installed RareScanner minimap tracking module and the primary project description at https://github.com/Krelock/NodeSight . No NodeSight implementation or media is bundled. This feature reads actual tracked-dot tooltips; the existing historical gathering database remains separate. HerbChime.wav and MiningChime.wav are original synthesized cues with generator source included in Tools/GenerateGatherChimes.py.

## Live detector compatibility · 0.18.1

Forever-generated API documentation: https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/MinimapDocumentation.lua — MinimapScriptTrackingInfo.spellID is optional. Detection now relies on real tracking tooltip contents rather than requiring this field. https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/MinimapFrameAPIDocumentation.lua confirms the soft-cursor and point-probe entry points. No third-party implementation was imported.

## Sparkle integration · 0.19.0

Source inspected: user-supplied `ForeverLootSparkles-v1.3.0-forever.zip`, manifest author Ashtar Senior, X-License GPL-3.0-or-later. SoftTarget.lua is adapted with retained attribution in Core/SoftTargetSparkles.lua; details in THIRD-PARTY-NOTICES.md. The archive includes source files and builtin texture fallbacks; no external downloads or runtime dependencies were added.
