# Spam Filter audit · 0.22.0

Date: 2026-11-07. Live target: `_forever_`, Interface 16001. Source/live v0.21.0 backed up before edits. No WTF/SavedVariables files are edited by the installer. Version is 0.22.0 in the addon manifest.

## Current addon review

| Primary source | Review finding |
| --- | --- |
| [CrossIgnore](https://www.curseforge.com/wow/addons/crossignore), [author source repository](https://github.com/LoyalFTW/CrossIgnore) | Extended ignores, custom word rules, trusted players and rule testing are relevant. Its preliminary Forever full-name notice makes careful realm/name handling necessary. |
| [Sift](https://www.curseforge.com/wow/addons/sift), [author repository](https://github.com/Royaleint/Sift) | Advertised gold/boost filtering on public chat and whispers is relevant. No implementation or filter corpus imported. |
| [Forever Chat Filter](https://www.curseforge.com/wow/addons/forever-chat-filter-wow-forever) | Channel selection and literal/whole-word filtering are useful references. The author explicitly distinguishes hiding lines from real ignores; it does not touch the game's ignore list. Our implementation supplies the additionally requested ignore records/bridge. |
| [BadBoy](https://www.curseforge.com/wow/addons/bad-boy) | Spam blocking is relevant; reporting behavior is outside this request and is not included. |
| [Absolute Spam](https://www.curseforge.com/wow/addons/absolute-spam) | Discovered through search, but the project page could not be opened in this session. Not used as implementation evidence. |

The inspected projects declare All Rights Reserved on their project pages. No third-party implementation, database, asset or addon dependency was added. Core/SpamFilter.lua and Core/SpamSettings.lua are independently implemented with the native UI.

## API verification

[Forever FriendList documentation](https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/FriendListDocumentation.lua) defines C_FriendList.AddIgnore, DelIgnore, IsIgnored/IsIgnoredByGuid, GetNumIgnores and GetIgnoreName. The addon prefers those APIs, supports available legacy equivalents and verifies observed results rather than treating pcall success as ignore success.

[Forever ChatInfo documentation](https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatInfoDocumentation.lua) defines incoming chat payload order, including stable zoneChannelID, local channel index, lineID and GUID. Secret values are never compared, formatted or saved. The filter handles ordinary incoming character chat; Battle.net chat and addon/system messages are excluded.

AutoMark clarification: [AutoMarkAssist v3.6.3 release notes](https://www.curseforge.com/wow/addons/automarkassist/files/9045743), sections 3.6.1+, explicitly state that Forever disallows autonomous raid icon changes, smart Mark Mob works before combat, and the game's own Raid Target keybindings are used in combat. No marking capability is added or claimed in this release.

## Implementation and integrity

- Account-saved local rules, trusted names and realm-aware full-name ignore records with first-blocked/last-seen timestamps. Native status is tied to the current character; it is not assumed to carry across characters.
- Literal word/phrase, contains and compact modes, enabled/hide-only controls, conservative built-in English gold ads, and custom per-sender auto-ignore.
- Rate-limited queued native adds, read-back confirmation, rejected/full/unavailable fallback, session stop on API errors, and combat deferral. Automatic-WoW-ignore off cancels queued automatic work; explicit retry remains an explicit action. Main off stops new work while preserving existing native ignores.
- Unignore verifies removal where possible. Unknown/failed removals remain in the visible management list. Imported old ignore dates remain unknown; observation time is labeled separately.
- Native tab, editor, searched/paged lists, 200-entry persistent history, trust controls and a test-only preview. Incoming messages do not rebuild/drop native dropdowns or editor state.
- Bounded message decisions prevent duplicate processing across chat frames. No player reports, chat responses, web requests or telemetry exist in the modules.
- All previous features remain in place. The obsolete test assumption of exactly seven tabs now checks the Gathering tab's identity so adding the requested eighth tab is supported. Settings labels/widths fit the shared row, with a bounded fallback for longer locales.

## Validation

`work/test_spam022.py` runs the full existing suite plus spam-specific scenarios. Passed: built-in RMT examples and ordinary trading corpus; custom literal, word, compact and Macedonian/Cyrillic matches; empty/duplicate rule rejection; one record/request across multiple chat windows; first/last timestamp retention; General/Trade moved to different channel numbers; disabled channel scopes; GM/self/friend/group/trusted exemptions; full names and realm separation; hide-only behavior; main/native/combat switches; manual retry; native confirmation, silent result timeout, missing API, false/rejected return backoff and thrown API error; unignore, failed/unknown removal visibility and honest old-list import; reload-pending recovery; per-character native-state reset; 200-entry history cap; all four native pages and multiline editor; secret message/author guards. All 2,122 Lua sources compile as Lua 5.1. Existing guide, gathering, gear, sparkle, transport, portrait and secure marking tests remain passing.

These are simulated client API and lifecycle tests, not a live spam/dungeon playthrough. Actual server ignore behavior and new spam variants still require in-game validation. The feature does not promise detection of every gold seller, cannot recover original dates for preexisting game ignores and does not bypass native ignore capacity or hidden chat data.
