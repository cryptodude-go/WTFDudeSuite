# WTF! DUDE SUITE 1.5

- Core + 12 independently selectable AddOns: Leveling, Professions, Reputation, Gathering, Arrow & maps, Auto quests & gear, Sparkles, Group marks, Ignore & spam, Rare scanner, Travel timers, Chat & statistics.
- Each optional addon depends only on Core. Disable/remove it in WoW's AddOns list and its Settings section disappears after reloading/restarting. Internal Settings master switches remain available for loaded modules.
- Optional feature implementations load from their own addon folders. All 1,989 leveling/translation scripts load only with the Leveling addon. Shared compatibility, quest data, native UI and cross-module services remain in Core.
- Compared Questie 12.9.0 with QuestieDB 1.1.1 Forever: 611 missing quest records and supporting missing 77 NPCs / 121 objects / 26 items added. Six existing quests were also restored to the native database reader. 71 incomplete/NYI records excluded; full reasons in QUESTIE-MISSING-1.5.csv.
- Imported facts retain eligibility/prerequisites; unsupported advanced conditions stay conservative until the quest is present in the live log. Existing reviewed facts and authored guide step order are preserved.
- 10 editable quest-completion messages + 10 editable level-up messages; random selection avoids immediate repeats. Random off uses the first nonblank entry. Blank entries are excluded; reset buttons restore defaults.
- Announcement channel switches remain separate for party/raid and quest/level. Level/event deduplication prevents repeated sends. Default messages mention WTF! DUDE; edits are retained per character.
- Removed live herb/mining probing, discovery sounds, sound selectors/previews and automatic live-node detours. Known/saved minimap circles, history, profession routes and route lines remain.
- Performance snapshot aggregates Core plus loaded optional addons. No background memory scan or automatic CPU profiling.
- Existing Core SavedVariables and character progress are retained. Installation never edits live WTF/SavedVariables.
