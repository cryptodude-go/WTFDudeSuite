# Group marking audit · 0.25.0

The old combat action was a single fixed Skull, so each new target took Skull from the previous mob. It did not implement sequential combat planning. Separately, pre-pull ownership reuse treated a mob absent from the newly selected pack as an ended pull even with unreadable positions.

Pre-pull order now starts Skull/Cross/Moon and reserves all eight assignments. Reclamation needs an explicitly ended pull, or readable separation over 60 yards outside the selected pack while both mob/group are quiet. Switching targets or hiding a nameplate alone does not qualify. Existing late party/mob regen, pet/unknown-state guards, external marks and failed-confirmation ownership remain tested.

Eight independent secure raidtarget set actions provide explicit combat control. Default main combat button is disarmed instead of repeatedly stealing Skull. Each icon has an independent binding, works with the bar hidden and rejects friendly/dead/absent targets and solo play through the existing secure state rule. Scope/settings updates remain deferred out of combat. Direct selection intentionally replaces that icon; this is explained in the tooltip. Legacy fixed-icon behavior remains opt-in and explicitly labeled.

Only observable casts/channels teach NPC-ID caster hints. Active casts get 400 extra priority; observed casters get 120; custom priority gets 1000, tank target 200 and selection 50. Existing assignments never get rearranged by scoring. Interruptibility comes from cast result 8 or channel result 7, with explicit unknown fallback. No health, danger, healer or interruptibility guess is made from an NPC name. CC suggestions still depend on party class/type compatibility and remain opt-in.

Validation: every addon Lua file compiles under Lua 5.1; full historical guide/equipment/sparkle/gathering/spam/quest/travel/navigation regression harness, plus dedicated v0.25.0 multi-target/caster/secure-button scenarios. Historical fixed-combat tests explicitly select legacy fixed mode; new tests exercise the new safe default. Secure actions are emulated using the published Blizzard handler; no real game combat was automated or verified. Source/live v0.24.1 backups saved before editing. Installer verifies release hashes and never edits WTF/SavedVariables.

Primary references inspected:
- https://raw.githubusercontent.com/Gethe/wow-ui-source/classic/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua (raidtarget action set)
- https://raw.githubusercontent.com/Gethe/wow-ui-source/classic/Interface/AddOns/Blizzard_RestrictedAddOnEnvironment/RestrictedEnvironment.lua (restricted snippets do not expose UnitGUID/GetRaidTargetIndex)
