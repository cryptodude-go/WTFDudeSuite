# Reset/evade marking fix · 0.23.2

Date: 2026-11-07. Source/live v0.23.1 backed up before edits. Install target is `_forever_`, Interface 16001. No WTF or SavedVariables files are edited.

## Root causes

The planner reserved every visible raid icon plus all owned/uncertain icons without distinguishing finished pulls. ReleaseFinishedPull deleted only unseen owned records, so a living mob returning home kept its slot indefinitely while visible. Deleting an unseen record also lost proof that a returning icon belonged to this addon, causing it to be treated as an external mark later. Confirming a transfer did not explicitly remove a hidden former owner of the same icon. Regen was checked once, missing a later group-member or mob reset. Tank-target preference could also override the user's newly selected target with a stale tank target.

## Fix

GroupQuiet requires every known group member and existing pet to report out of combat. An incomplete grouped roster or unreadable combat state is not assumed safe. Regen marks the pull pending and is retried by Scan until members/mobs are quiet. Finished-pull flags preserve ownership even off-screen, including delayed/ambiguous confirmations. A missing unit may be reclaimed only while the group is confirmed quiet. A visible owner must itself explicitly report out of combat.

While the player selects a new enemy, only addon-owned marks outside the selected pack, or owned marks flagged from a finished pull, become reusable plan slots. External marks, current-pack pre-pull assignments, active group/pet fights and uncertain visible mob combat states remain protected. The explicit target defines the selected pack before a stale tank target. A selected Cross that the addon owns may be promoted to a reclaimed Skull on the next real press; manual/external marks and CC marks are not promoted. Revalidation checks that the Cross still belongs to our recorded target before arming.

The scan changes no actual mark. The next hardware click/key invokes the existing secure set action. Ownership is not discarded on an attempted or failed transfer. RememberMark removes conflicting old records for that icon only after the game exposes the new mark. A pending confirmation that crosses regen retains its finished-pull flag. Target and RAID_TARGET_UPDATE events refresh only the read-only plan/confirmation UI. The v0.23.1 fixed combat-target secure state snippet is unchanged.

## Validation

work/test_marks0232.py runs the entire previous release chain and adds focused reset scenarios: living evade without death; late party and mob combat exit; current-pack preservation; explicit own-Cross promotion; distant and unseen prior packs; twenty scans with no mark or protected-attribute changes; manual/external icons; missing group roster; active pet; all eight stale slots; unknown combat state; confirmation delayed across regen; uncertain old attempts; failed transfer preserving old ownership; retry cleanup; simultaneous group combat. Existing full suite covers secure combat clicks, key/bar separation, scopes, quests/zones, gathering, spam filtering, gear, sparkles and navigation. All Lua files compile under Lua 5.1.

This is source inspection and mocked-client verification, not a live Forever evade playthrough. The client still determines actual raid-mark permissions. Hidden external marks cannot be discovered reliably by this addon; only recorded ownership is reused. No claim is made that automated checks prove the addon free of all possible bugs.
