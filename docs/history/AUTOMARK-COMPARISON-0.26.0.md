# AutoMarkAssist comparison · Dude, Where’s My Ding! 0.26.0

Reviewed 7 November 2026: published AutoMarkAssist v3.6.3, CurseForge file 9045743; archive SHA-256 4119d63e75f7d49f255f01fa3808bf654b3f522666fe49f23ea8aebc52c5a2ea. Primary release page: https://www.curseforge.com/wow/addons/automarkassist/files/9045743

The general project description describes multiple Classic clients. Its 3.6.1 changelog explicitly corrects the earlier 3.6.0 Forever claims. Independently rerunning the archive's client detector, mode selector and protected-call guard with Interface 16001 yields key mode, zero direct marking calls, no death cascade and a combat-blocked smart Mark Mob key in both 3.6.2 and 3.6.3. No live game marking was exercised by this test.

## Module review

Core handles secret reads, group authority, protected-client detection, deferred combat changes and owned icons. MobScanning separates unit collection, danger scoring, database preference, CC compatibility, mark commitment, synchronization, death detection and cascade. Main defines settings, class CC assignments and allocation of extra CC icons to duplicate classes. Proximity and Mouseover run the pack allocator on unrestricted clients; the effective Forever mode bypasses them. MarkKey plans one unit per hardware press out of combat, has pending confirmations and a hidden-identity sequence. Events coordinates initialization, roster/zone/combat changes, health/death checks and reset bindings. Manual is a modifier/scroll HUD with saved preferences; this automatic Lua path is disabled on Forever. DBTab browses zone/expansion records and player overrides. Config/Tutorial/Minimap expose the settings, guidance and status. The five expansion database files contain curated mob preferences, creature types, immunity and danger metadata; that third-party database is not redistributed here.

## Comparison

| Behavior | AutoMarkAssist on Forever | Our addon 0.26.0 |
|---|---|---|
| Smart key outside combat | One planned icon per key, mouseover then target | One scored pack candidate per key; target/mouseover/tank and optional nearby pack |
| Order | Preference, Skull, Cross, compatible class CC | Personal preference, Skull, Cross, optional compatible class CC, unreserved spare kill icons |
| Existing marks | Owned/pending and global occupancy | Visible/owned/uncertain plus global occupancy; off-screen marks are now reserved |
| Duplicate classes | Extra players borrow spare CC icons | Implemented; primary claims retained, roster aliases deduplicated |
| CC immunity | Database/manual; no combat-log learning on Forever | Selected-NPC manual flag; no guessed immunity or restricted combat-log access |
| Danger | Curated instance database and personal overrides | Observed cast/channel hints plus personal NPC-ID danger/preferences/skip rules |
| Clear all | Secure clear-all hardware key | Secure clear-all button/key; verified state before resetting tracking |
| After combat | Blind sequence bookkeeping restarts; automatic clearing disabled | Ended-pull recovery without automatic clearing; external/global reservations preserved |
| Combat smart sequence | Disabled | Disabled; eight direct secure icon buttons/keybinds are available |
| Death cascade | Disabled by protected-client guard | No automatic moving of marks in combat; confirmed deaths release ownership |
| Hidden NPC identity | Blind order and set-unmarked action | Fail-closed smart planner; explicit icon controls still available. No fake caster/type guess |
| UI/database browsing | Standalone tabs, zone browser, tutorial | Native leveling settings, selected NPC editor, movable marker bar; no full zone DB browser |
| Announcements | Configurable party announcements | No new chat announcements |

The archived MarkKey uses action `set-unmarked`. The published Blizzard secure raidtarget handler inspected for this work documents set, clear, clear-all and toggle; therefore we do not copy that hidden-identity behavior or assume it is supported by the installed Forever build. Safe readable planning and explicit secure controls are retained.

## Working example

1. Enable Group marks; select the pack outside combat. Mark next gives Skull, then Cross, then optional compatible CC/spare icons. Existing assignments remain stable as targets change.
2. With Suggest crowd control enabled, two Mages can receive Moon and a borrowed unused icon on compatible mobs. A manually immune NPC is excluded from those CC slots.
3. To prioritize a known healer/summoner, select it and set Selected NPC danger to Critical. This personal rule is saved by NPC ID. Preferred icon and Skip/Immune are independent options.
4. In combat select a mob and press the desired direct icon button/keybind. This intentionally replaces that icon; it is not an automatic free-icon sequence.
5. To start a complete fresh marking plan, press Clear ALL marks. This removes marks from the entire group, including other people's marks and off-screen mobs. If game state cannot confirm it, the addon keeps tracking and says so.

Primary sources: release/changelog above, inspected release archive, and Blizzard's published SecureTemplates.lua / RestrictedEnvironment.lua. These changes are independently written and do not bundle AutoMarkAssist code or its proprietary database. This comparison does not claim full addon parity or real-client combat verification.
