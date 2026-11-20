# Group marks audit · 0.21.0

Reviewed 2026-11-07. Target: live Forever Interface 16001. Source and live 0.20.0 were backed up before changes. Character WTF/SavedVariables files are not edited by the installer.

## Research and supported behavior

[AutoMarkAssist project](https://www.curseforge.com/wow/addons/automarkassist), [v3.6.3 changelog](https://www.curseforge.com/wow/addons/automarkassist/files/9045743), and the downloaded v3.6.3 archive were inspected. The linked public GitHub repository returned 404; the public CurseForge release archive was available.

The detailed 3.6.1+ release notes correct the broader description: Forever protects raid-target placement; automatic proximity/mouseover, combat cascade and auto-reset are unavailable there. Its marking key works before combat, while native game bindings are needed in combat. This distinction is reflected in our labels and documentation, rather than presenting a nonworking automatic checkbox.

API reference: [Forever Blizzard SecureTemplates.lua](https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua), SECURE_ACTIONS.raidtarget (`unit`, `marker`, `action=set-unmarked`). Our module uses this action from an actual click/key press and a secure combat state driver that only disarms it. No insecure protected-function probe is made.

AutoMarkAssist is All Rights Reserved. No implementation, mob database, UI assets, defaults table or other file from its archive is included in this release. Core/GroupMarks.lua is an independent implementation under our package license. It uses our native settings widgets and private saved state. No AutoMarkAssist dependency/installation is required.

## Changes

- New native Automation controls and detail page, native keybinding, movable per-character bar and independent invisible key button, with an off-by-default master switch.
- Pre-pull group-aware planning with current/tank target preference, visible pack bounds, manually remembered NPC priorities, optional group/type CC suggestions, and marker reservations.
- Scope/permission validation on the actual click, not just while drawing the preview.
- Confirmation before claiming mark ownership; dead/manual-changed owners release reservations. Unconfirmed outcomes keep a separate uncertain reservation until disproved. Own unseen reservations can be released only after every group member is confirmed out of combat. Existing visible marks and marked friendly members are preserved.
- Secure attributes, drivers, frame movement and visibility setup occur outside combat. Settings changes requiring layout wait for combat to end. The secure state driver disarms a prepared action if combat begins.
- Old Compat.MarkTarget is guarded on Forever and the unsupported solo automatic-mark checkbox/empty section is removed.

## Validation

`work/test_groupmarks021.py` includes the previous full regression suite plus the group-mark scenarios. Tests simulate the client performing the secure action between PreClick and PostClick; the addon is never allowed to call SetRaidTarget in that simulation.

Passed: no automatic calls/arming after 30 scans; one mob per click; Skull/Cross/spare kill icons; group CC compatibility; existing hostile/friendly marks; confirmed ownership, death and manual override; single mob, distant packs, explicit mouseover; party/raid/dungeon/outdoor/PvP switches; leader/assistant permissions; combat attribute/layout deferral; missing/secret/failed API data; recycled unit tokens; rejected/asynchronous confirmation; settings and binding rows; off switch; uncertain outcome reservation and readable rejection; finished-pull cleanup with active-group guard; hidden-bar key independence; draggable position persistence and combat drag guard. Static assertions reject direct SetRaidTarget calls, simulated clicks, combat-log subscriptions and chat broadcasts in the new module. All 2,120 Lua files compile as Lua 5.1. Previous 221-guide/13,216-step/90-compatibility checks, level catchup, transport clocks, gathering, gear and sparkles remain passing.

The secure action itself is a Blizzard implementation and cannot be executed by the Lua mock. These checks validate our planning and lifecycle contracts; a real before-combat key/click test with appropriate group permissions remains necessary. No claim of fully automatic marking or live dungeon playthrough is made. Unreadable identity/mark data deliberately stops smart planning; off-screen marks placed by other players remain unknowable.
