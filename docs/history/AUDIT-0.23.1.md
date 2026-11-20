# Combat marking fix · 0.23.1

Date: 2026-11-07. Source/live v0.23.0 backed up before edits. Correct target is `_forever_`, Interface 16001. No character saved files are edited by installation.

## Reproduced causes

Core/GroupMarks.lua explicitly rejected Prepare while in combat; its secure state handler cleared type on combat entry. Thus the existing key could never mark in combat. This was a design limit in our pre-pull planner, not intermittent target prioritization. Inspection also found pre-pull action `set-unmarked`, which is not a supported SECURE_ACTIONS.raidtarget action in published Blizzard UI source. The old mock accepted it without checking the real action, masking that issue. It is now `set`, and the regression emulator rejects unsupported action names.

## Changes

The existing visible/key secure frames retain their binding IDs. Out of combat, scope checks snapshot a fixed combat icon and permission flag. A secure state handler arms type=raidtarget, unit=target, marker=the configured constant, action=set when `[combat,group,@target,harm,nodead]` is true. Other states disarm. This does not place a mark: a real hardware click/key release invokes Blizzard's secure action. Insecure PreClick/PostClick callbacks never change protected attributes in combat. No addon SetRaidTarget, simulated Click, timer-driven action, macro execution or combat-log subscription is introduced.

The fixed combat action intentionally follows the player's current target, rather than a stale pre-pull nameplate token. A second press preserves the same icon; selecting another enemy and pressing transfers the selected icon, including intentional replacement of its prior mark. This is explicit user-controlled marking, not automatic priority/CC/cascade decisions in combat. Before pull, smart pack suggestions and preserving existing icons remain unchanged.

Two settings in Group marks: Mark my target in combat (on by default within the master assistant) and Combat target icon (Skull default, all eight supported). Settings/layout and scope/leadership changes during combat are deferred. Secure group/target conditions and actual game authority still apply at execution; the leadership/location settings are a pre-combat snapshot. An assistant enabled only after entering combat becomes ready after leaving combat. Native APIs may additionally deny a mark; pending requests are confirmed only by actual readable icon state, with honest timeout notices. Hidden GUID/nameplate data does not disable the fixed secure target action.

## Primary source checks

- https://raw.githubusercontent.com/Gethe/wow-ui-source/classic/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua — published Blizzard UI secure raidtarget implementation supports set, clear, clear-all and toggle. Set does not toggle the selected marker off.
- https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua — corresponding secure templates and modified-unit resolution.
- https://www.curseforge.com/wow/addons/automarkassist — current project and downloaded v3.6.3 MarkKey.lua were rechecked. That implementation dynamically prepares its smart button only out of combat. It does not prove automatic combat planning is available on Forever. No AutoMarkAssist code copied.

## Validation

work/test_marks0231.py runs the complete previous release chain, including the level/zone fixes, and then executes our actual state snippet in a controlled Lua 5.1 harness. Protected attribute writes fail unless the harness is executing the secure state snippet. Tests cover visible and independent key buttons in combat, repeated click preserving a mark, target changes, no timer marking, hidden GUID data, friendly/dead/absent/solo disarming, queued settings, selecting a different combat icon, hidden bar, master/party/raid/location/leader scopes and recovery of pre-pull marking. It separately verifies no direct protected marker calls and the supported set action. All Lua files compile. Existing quest, gathering, spam, sparkles, gear and navigation checks remain passing.

The harness emulates native secure execution; it is not a live Forever combat playthrough. In-game confirmation of the current client's protected action behavior and group permissions is still required.
