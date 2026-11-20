# Forever review — 0.13.0

Research checked 2026-10-20. This is a standalone Horde guide update, not a claim of complete beta coverage or live playtesting.

## Implemented

- Correct Skyborne quest-mask arithmetic: race IDs 95 and 96 use bits 2^32 and 2^33. Unknown race IDs fail closed for race-restricted pickups. Accepted Normal-mode quests and positive NPC offers still use the server's eligibility decision.
- Zephras Isle uses native UiMap 2521, rather than depending on its English name or a continent scan. Area ID 16593 is kept separate from the UiMap ID.
- Refreshed native names for 756 new Forever quest records. 667 names differed from the translated secondary index. Restored 213 matching factual records from our earlier snapshot, including objectives, questgiver IDs and known positive XP rewards.
- Refreshed 146 native questgiver names, with native Zephras questgiver coordinates when exposed. No quest story text or third-party guide scripts are bundled.
- Added zone membership for class/utility quests with an indexed pickup map. Removed unavailable and Alliance-only new records from the Horde zone lists; their lookup records remain for accepted live quests.
- NPC gossip offers can unlock otherwise unverified pickups for the current character. This is positive evidence only: not seeing an offer never marks a quest impossible. Offers expire after 30 minutes and invalidate on quest acceptance, completion, removal or zone change. Eligibility is never saved or shared; observed names and pickup locations are saved locally per character.
- All existing user filters still apply to live offers. Missing/throwing gossip APIs do not interrupt the guide.
- Zephras has no Classic-only speedrun route. Selecting Speedrun there displays an explanation; a saved Speedrun selection falls back to Normal. The player can select Speedrun after leaving. Forever quests are not silently added to Classic speedrun lists.
- Chapter pending counts now include unverified prerequisites. `/dudeding debug` reports factual index/location coverage separately from verification.

## Coverage

The broad lookup remains 4,995 indexed records. The current Horde/shared zone books contain 2,297 distinct entries, including 322 marked new Forever entries. 408 entries need navigation or prerequisite verification. Zephras has 121 zone-book entries, including class/related records; the current secondary index categorizes 109 quests directly under Zephras. These counts describe records, not a fully playable, ordered 121-quest route for one character.

The broader new-quest index also includes profession, class, dungeon, event and other-faction quests. All 756 native-name records are not claimed as Horde outdoor leveling steps. Unknown prerequisite chains remain conservative until the NPC offers the quest or it is accepted. Visual website chains do not establish whether prerequisites are AND, OR or mutually exclusive branches.

## Other addons reviewed

| Project | Relevant approach | Result for our addon |
| --- | --- | --- |
| [Questie / QuestieDB](https://github.com/Questie/QuestieDB) | Separate Forever database, native map IDs, explicit race flags, chain restrictions | Corrected race/map handling. No Questie database copied or dependency added. |
| [Lodestar](https://github.com/danielcosta42/lodestar) | Skyborne routes, eligibility filters, mid-level synchronization | Retained live-log resynchronization; added positive server-offer evidence. No guide scripts copied. |
| [ForeverGuide](https://github.com/prezus/ForeverGuide) | Separate guide engine and reference data | Retained standalone operation; no undocumented CVar workaround adopted. |
| [ForeverWisp](https://www.curseforge.com/wow/addons/foreverwisp) | Starter guidance, gathering assistance | Existing profession/gathering guidebooks retained and regression-tested. |
| [Guidelime](https://www.curseforge.com/wow/addons/guidelime) | Guide/context filtering and automatic progression | Existing class, quest-history and completion checks retained. |
| [QuestTrail](https://www.curseforge.com/wow/addons/questtrail) | Learning quest facts from gameplay | Added local-only positive NPC observations. No external sharing. |
| [RestedXP](https://www.curseforge.com/wow/addons/restedxp-guide) | Leveling-guide product comparison | No paid guide content imported. |

This is a representative review of available projects and public documentation, not execution/testing of every addon or every guide pack.

## Sources and remaining gaps

- [Blizzard: Meet the New Skyborne](https://news.blizzard.com/en-us/article/24302071/wow-forever-meet-the-new-skyborne): Zephras levels 1–12; Horde and Alliance branches. This release's guidebooks remain Horde-focused.
- [Native Forever quest endpoint example](https://nether.wowhead.com/forever/tooltip/quest/92462) and [NPC endpoint example](https://nether.wowhead.com/forever/tooltip/npc/251362): names and exposed factual coordinates. No narrative reproduced.
- [WCLBox quest index](https://wowforever.wclbox.com/shuju/en/renwu/list.json) and [Zephras category](https://wowforever.wclbox.com/shuju/en/renwu/c/zephras-isle.json): secondary factual index, build 1.60.1.70450. Native/client names take precedence over its translated labels.
- [QuestieDB Forever documentation](https://github.com/Questie/QuestieDB/blob/master/docs/forever.md): reference for race/map conventions and incomplete beta coverage. No GPL database included in this release.

Remaining work requires actual beta playtesting: both Skyborne branch eligibility, changed quest objectives, quest chains without authoritative prerequisites, and map landmarks in altered zones. Classic reference coordinates in changed zones are not certified by this review. Native accepted-quest waypoints and locally observed NPC positions take priority, but that does not prove every fallback coordinate correct. Camping and other Forever-only profession leveling routes are not implemented. Alliance leveling routes are not included.

## Validation

Passed the full active-TOC Lua 5.1 mock suite, all 27 visible switches, all 12 profession skill bands/ranks, hover/material estimates, combat deferrals, guidebook transitions, frame reuse and announcement controls. Additional tests cover both Skyborne race-mask branches, localized Zephras map resolution, all 756 refreshed names, restored objectives/rewards, offer expiry/invalidation, user filters, missing APIs, duplicate zone steps and island coordinate bounds. These are automated logic tests, not native WoW rendering or full-route playthroughs.
