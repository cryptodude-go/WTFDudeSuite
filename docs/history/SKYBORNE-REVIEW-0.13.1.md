# Skyborne pickup repair — 0.13.1

The 0.13.0 release could track accepted Skyborne quests but withheld their pickup waypoints. Two independent gates caused this: every new quest retained `prerequisitesUnverified`, and many shared island quests inherited an Alliance-only race bit. Positive NPC offers bypassed these gates, which explains why manual acceptance appeared to fix the guide. This was an implementation defect in our previous release.

## Corrected behavior

A fresh Horde Skyborne Druid, with empty saved settings and no accepted quests or NPC gossip interaction, is directed to Ailee Farheart (42.8, 23.4) to accept Coming of Age. Completed quest history unlocks Harmony in Balance and Infestation Investigation; Harmony completion and level 2 unlock A Student of Nature for Druids. Hunter, Rogue, Shaman and Warrior trainer quests remain restricted to their classes.

The island catalogue now has reviewed minimum levels, shared/Horde/Alliance flags, questgiver/finisher IDs, typed AND/OR prerequisites, exclusive alternatives, breadcrumb expiry and profession/spell requirements. Shared quests are scoped to both Skyborne race bits rather than the earlier incorrect Alliance-only bit. Source references that assume all races are not expanded to all races in our addon. Branch-specific faction flags remain separate.

Native NPC names and available spawn coordinates were checked for all 72 unique questgivers/finishers referenced by 140 related quest records. 70 have native island positions; two finish outside the island. The Horde/shared NPC pickup subset contains 119 quests. The remaining records include other-faction branches and item-start quests. Counts do not imply that one character can accept all quests.

Multiple recorded NPC positions use the native spawn nearest that quest's indexed giver/finisher position. For example, Vayn Moongaze has both (63.7, 38.0) and (63.8, 36.0); the related pickup uses (63.8, 36.0). A locally observed quest interaction takes priority. Accepted objective waypoints retain native-client priority.

The Zephras route revision changes from 2 to 3 so stale blocked/skipped route state is rebuilt once on update. Completed quest history is retained. Normal mode is required; the Classic-only Speedrun policy is unchanged.

## Review sources

- [Native quest example: Coming of Age](https://nether.wowhead.com/forever/tooltip/quest/92460), [Druid trainer quest](https://nether.wowhead.com/forever/tooltip/quest/92485), and [Ailee Farheart](https://nether.wowhead.com/forever/tooltip/npc/251362): canonical names and exposed location facts.
- [WCLBox Zephras category](https://wowforever.wclbox.com/shuju/en/renwu/c/zephras-isle.json) and [quest chain example](https://wowforever.wclbox.com/shuju/en/renwu/q/92460.json): secondary location and chain cross-checks, not copied guide narrative.
- [QuestieDB factual Skyborne records](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua) and [correction reference](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua): cross-check of questgiver IDs, class/branch constraints and AND/OR semantics. Shared-race upstream assumptions remain assumptions; source-reviewed records are not represented as live client acceptance evidence.
- [Lodestar Horde Skyborne route](https://github.com/danielcosta42/lodestar/blob/main/Guides/Leveling/Horde/Zephras_Isle_5-12.lua): cross-check of the starter/trainer sequence. No guide script or prose is included in this release.

SkyborneData.lua is an independently formatted factual catalogue. No full external database or other addon's runtime is shipped. SKYBORNE-QUESTGIVERS.csv lists each reviewed quest, minimum level, class/branch, pickup NPC, position and typed prerequisites.

## Validation and limits

Automated Lua 5.1 tests start from a genuinely empty character database and verify the initial pickup waypoint, next-pickup progression and the Druid trainer unlock without manual acceptance or NPC offers. Tests also cover all five Horde Skyborne class gates, every one of the 119 Horde/shared NPC pickups with its individual requirements satisfied, multi-position NPC selection, AND/OR prerequisites, branch separation, obsolete breadcrumbs, profession requirements, known-spell exclusions and upgrade recovery without losing completed history. All 140 reviewed records pass prerequisite-cycle checks. The existing settings/profession/UI regression suite also passes.

These are source review and automated logic tests, not a live beta quest playthrough. Beta phasing, NPC movement and quest availability can still change. The addon remains Horde-focused; Alliance branch data is retained for correct filtering, not a claim that Alliance leveling guides are included.
