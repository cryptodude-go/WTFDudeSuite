# Ding v1.8.1 review and integration · 0.16.0

Reviewed 22 October 2026 from the attached archive. This report distinguishes imported guide/data sources from runtime features actually implemented.

## What was inspected

The archive contains 1,884 files. The inventory covers every Core/UI module: 44 modules and 747 named public functions. Guide analysis loaded all 221 English guide files in an isolated parser, counted every source instruction and classified every used step field. Detailed integration focused on registry/filtering, quest state, conditions, prerequisite handling, data export, optional quest automation and six-tab configuration. Other module features were inventoried and are explicitly marked below; inventory is not a claim of running every original subsystem.

## Guide/data integration

86 leveling sections, 75 starter/zone sections, 18 class sections, 41 dungeon sections and one item section are included. All 13,216 original source steps remain represented; combined quest actions normalize to 16,571 executable/checkable instructions. The guide files remain separated by faction, race/class and purpose. Their 2,725 referenced quest IDs all resolve in the combined reference database.

Raw source export: 5,226 quests; 13,392 NPCs; 6,994 objects; 21,279 items. Integration adds 172 missing quest records, fills 1,962 empty objective records and 2,058 pending pickup records, and updates 2,923 start/contact mappings. Existing zone books receive 1,278 additional entries before filtering. NPC/object coordinates are used lazily with short-lived position caches rather than duplicating every normalized spawn at startup. Local observations/native live waypoints and previously reviewed Skyborne data retain priority.

Authored library progress is separate from existing zone progress. Every original guide field is retained in its readable source definition. Quest, item-count, level/XP and walking conditions have completion checks. Trainer/hearth/flight/bank/cleanup/service actions not reliably exposed by the client use explicit Next confirmation. Floor hints are displayed; source sticky/patrol metadata is retained but does not gain Ding’s concurrent execution engine. Guide-level prerequisites can recover earlier missing quests, bounded to avoid cycles; positive server offers override incomplete prerequisite reference evidence.

## Settings and retained behavior

Six tabs: Guide, Route, Automation, Arrow & maps, Keybinds, Appearance. Dark/opaque styling, guide categories and character matching, searchable library/chapters, green ON/OFF state badges, preserved existing controls and native WoW keybinding declarations. Optional quest-pane assistance starts OFF. Existing profession, reputation, gathered-node history, recent-visit exclusions, target/model previews and minimap/world-map lines remain. New Alliance characters can select/default to matching authored routes; the old dynamic zone planner remains Horde-focused.

## Original module comparison

| Original module | Named functions | Integration status |
| --- | ---: | --- |
| Core/Along.lua | 5 | Quest step order retained; concurrent along/sticky execution not ported. |
| Core/AutoQuest.lua | 6 | Independent opt-in active-guide acceptance/turn-in, no reward choices. |
| Core/Commands.lua | 0 | Existing equivalents retained where applicable; original module not directly imported. |
| Core/Compat.lua | 93 | Existing equivalents retained where applicable; original module not directly imported. |
| Core/Data.lua | 46 | Read-only export adapted into existing references; native/local observation priority retained. |
| Core/Ding.lua | 5 | Existing equivalents retained where applicable; original module not directly imported. |
| Core/DingDB.lua | 5 | Private data only; no LibDingDB global exported. |
| Core/Directory.lua | 28 | Reference NPC positions retained; full service directory UI not ported. |
| Core/Engine.lua | 65 | Authored quest order and conditions adapted; manual confirmation for unsupported completion signals. |
| Core/Gear.lua | 6 | Not ported. |
| Core/Goals.lua | 14 | Item counts and manual service/item instructions; concurrent sticky execution not ported. |
| Core/Grind.lua | 8 | Level targets retained; no Ding grind-spot scoring engine. |
| Core/GuideText.lua | 2 | Existing equivalents retained where applicable; original module not directly imported. |
| Core/Import.lua | 8 | All bundled guide definitions adapted; third-party text import UI not ported. |
| Core/Locales.lua | 0 | Existing equivalents retained where applicable; original module not directly imported. |
| Core/Merchant.lua | 4 | Manual instructions only; no automatic selling. |
| Core/Passages.lua | 11 | Floor hints/manual instructions retained; no full passage graph. |
| Core/Registry.lua | 11 | Replaced by private guide registry and character-filtered library. |
| Core/Report.lua | 7 | Not ported. |
| Core/Rewards.lua | 5 | Existing reward UI retained; Ding reward scoring/choice not ported. |
| Core/Services.lua | 5 | Existing equivalents retained where applicable; original module not directly imported. |
| Core/Talents.lua | 8 | Not ported. |
| Core/Timing.lua | 5 | Not ported. |
| Core/Training.lua | 3 | Manual trainer instructions; automatic purchase not ported. |
| Core/Travel.lua | 14 | Source travel instructions/coordinates retained; full transport engine not ported. |
| Core/Why.lua | 13 | Existing equivalents retained where applicable; original module not directly imported. |
| UI/Arrow.lua | 29 | Existing arrow and route lines retained. |
| UI/Config.lua | 28 | Six intent tabs adapted to existing options. |
| UI/Finder.lua | 22 | Category/character/search guide library adapted. |
| UI/Gamepad.lua | 33 | Not ported. |
| UI/ImportWindow.lua | 17 | Not ported. |
| UI/ItemButton.lua | 13 | Existing secure quest item controls retained. |
| UI/Minimap.lua | 4 | Existing minimap button retained. |
| UI/MinimapPins.lua | 3 | Existing map/minimap pins and lines retained. |
| UI/Offers.lua | 18 | Existing positive NPC-offer observations retained. |
| UI/Panel.lua | 51 | Existing compact tracker retained. |
| UI/QuestMobs.lua | 15 | Existing quest nameplates/target previews retained, enriched with missing objective links. |
| UI/Report.lua | 25 | Not ported. |
| UI/Rewards.lua | 5 | Existing reward UI retained; Ding reward scoring/choice not ported. |
| UI/Setup.lua | 17 | Guide library entry added; no separate Ding onboarding wizard. |
| UI/TaxiMap.lua | 3 | Not ported. |
| UI/Themes.lua | 9 | Existing dark theme retained; no new light mode or imported theme assets. |
| UI/TomTom.lua | 6 | No new dependency; existing own waypoint system retained. |
| UI/Widgets.lua | 72 | Independent existing widgets and explicit state badges retained. |

## Not included / limits

No full feature parity is claimed. Ding’s gamepad controls, talent planner, automatic gear/reward scoring, transport/passage graph, detailed timing/report interface, import editor, translation packs, concurrent sticky/patrol engine and its UI assets/fonts are not copied into the runtime. Source travel/service instructions remain usable with manual confirmation. Lines are straight visit-order previews, not terrain pathfinding. Beta phase/availability changes and native UI rendering still need live playtesting.

## Validation

Automated Lua 5.1 checks cover all guide compilation/referenced IDs/original-step retention; faction/class/race matching; actual Orc starter accept→objective→turn-in; resume and original progress isolation; every condition family; missing prerequisite recovery; item/travel/manual completion; next-section transitions; combat deferrals and latest-intent selection; all six settings tabs/categories and frame reuse; quest automation scope/defaults/Shift/reward-choice guards; native/local waypoint precedence; Alliance starter selection; existing profession/reputation/Skyborne/smart quest/gathering regression suites; and a visible minimap trail for an authored guide.

These are mocked-client logic checks, not full in-game route playthroughs. Every game quest and location has not been personally verified.

## Source and layout

See THIRD-PARTY-NOTICES.md and Licenses/. Original source headers/credits are retained. Core/, UI/, DB/ and Guides/ are loaded once in the original dependency order plus the new integration modules. MODULES.json records the old-to-new file mapping. The addon remains DudeWheresMyDing and never shares DingDB or a Ding global namespace.
