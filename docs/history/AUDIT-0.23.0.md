# Level and zone routing audit · 0.23.0

Date: 2026-11-07. Target: Forever Interface 16001, live `_forever_` folder. Source/live v0.22.0 backed up before edits. No WTF or SavedVariables files are edited.

## Findings and changes

The original Engine.isGrey exempted every prerequisite used anywhere in the guide and every accepted quest. QuestReconcile only adapted outleveled sections, not individual quest chains. Zone sections followed their `next` into another zone and could be replaced by level adaptation. These behaviors combined to reintroduce old Sepulcher pickups at level 22.

Core/QuestPolicy.lua centralizes explicit quest-level limits and zone checks. The private Engine.isGrey calls it, covering internal completion/pickup paths as well as public API consumers. GuideProgress supplies its candidate guide context rather than leaking the active guide's zone. Mixed steps retain eligible actions; excluded actions and their coordinates/previews disappear without mutating guide definitions. Nonquest travel to an obsolete hub is skipped when no eligible quest work remains. Trainer/vendor/repair chores retain their own completion rules. Local ready turn-ins are retained, while incomplete obsolete quests are left in the log without navigation.

Missing prerequisite chains are checked to depth 15, with cycle guards, group/all and single/alternative semantics. Excluded prerequisites cannot be revived by catch-up; already completed alternatives unblock their child. Unknown levels are retained. Every known giver, receiver and objective group must offer an in-zone point, and final candidates are clipped to the selected maps. The 75 built-in zone sections have explicit zoneMaps from their original English titles; the Hillsbrad/Alterac/Arathi section deliberately retains all three, rather than a guessed dominant map. No map names from localized clients are compared.

Zone mode stops automatic transitions to different maps, disables automatic chapter replacement, filters nearby/sticky/fallback points and AutoQuest wants, and shows an explicit empty-zone message. The original section remains selected until the player changes it. Nonleveling guide categories and auxiliary skill/reputation books are exempt from XP policy.

## Primary references reviewed

- https://github.com/moust4ki/DingGuideWoWForever — author documentation and current Core/Engine.lua. Its current source retains the broad prerequisite exemption; an upstream update alone would not fix this case.
- https://raw.githubusercontent.com/moust4ki/DingGuideWoWForever/main/Ding/Core/Engine.lua — engine source reviewed for resume, gray quest, prerequisites and chapter transitions.
- https://bindonforever.com/articles/bof-guide-0-9-81 — author describes starting from live quest progress and finishing a selected zone rather than moving by level alone. No BoF code copied.

## Validation

work/test_quest023.py runs the complete existing regression chain, then reproduces real Silverpine quest 435 at player level 22, checks old pickup coordinates/automation/catch-up, selected-zone preservation and finished-zone fallback cleanup. Controlled tests cover 13 level differences, alternative/group/completed prerequisites, active old quests versus ready hand-ins, mixed steps, out-of-zone travel and quest locations, category exceptions and settings opt-outs. All 75 zone sections have valid map metadata, including multi-zone sections. All Lua files compile under Lua 5.1. Existing 221 guides / 13,216 steps / 90 race-class-faction compatibility scenarios and spam/group-mark/gathering/sparkles/equipment/navigation checks remain passing.

These are mocked-client and source/data checks, not a live character playthrough. Quest locations and levels depend on the bundled database; unknown locations are not invented, and changing server data may need a database correction. This release improves routing policy; it does not claim all live Forever quests have been independently replayed.
