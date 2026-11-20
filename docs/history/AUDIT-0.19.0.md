# UI, sparkles and notification audit · 0.19.0

## Implemented

- All five supplied sparkle categories integrated into native Appearance settings; no standalone upstream options category/global dependency. Soft-target visual runtime retains its GPL attribution. Private per-character settings are in DudeWheresMyDingDB.sparkles. Quest highlight CVars are reapplied after graphics resets and deferred in combat. Approaching glints stop in combat; all approaching categories off restores saved CVars.
- Party/raid message switches and message editors appear directly in Automation. Level accounting uses a monotonic level across explicit events, UnitLevel and cached data. Quest objectives announce once per accepted quest, with repeatable acceptance resetting that guard.
- Tracker header is guide-only; race atlas/player portrait with circular mask/ring and current level medallion is added beside the tracker. Portrait inherits visibility and scale, supports tracker dragging and has an Appearance switch.
- Player-facing legacy brand strings updated throughout UI locales. Source credits and licenses remain. Internal frame and saved-variable names remain compatible.
- Reports are local text exports, retained in the existing last-20 report store. Upstream issue URL and link controls removed; filename and explanatory text corrected. No data is sent automatically.
- Mining/herb physical minimap hover is read without moving the player’s cursor. Scanner handles named color escapes and explicit skill suffixes. A valid map position permits scanning instanced maps too; the instance flag alone no longer blocks herbs/ore. Gathering status exposes ranks, probe/tooltip counts, last text and errors rather than silently appearing enabled when blocked.

## Validation

`work/test_release019.py` passes the full native guide/settings/navigation/route/dropdown/live-gather regression chain, then exercises repeated level events with stale UnitLevel/cache data in party/raid, disabled channels and quest-completion flicker. It verifies direct settings controls, tracker title, portrait level, report generation/no destination, all five sparkle checkmark callbacks, graphics resets, combat-deferred writes, ore/herb/quest/corpse classification, loot eligibility, far/ready/locked states and CVar restoration. Physical minimap-hover simulation verifies UI-scale conversion, named colors, one sound, arrow/line detour and insufficient-skill explanation. Lua 5.1 syntax is checked for every Lua source file. Packaged and installed files are hash-verified.

These are mocked-client checks; no live WoW gameplay or visual runtime was controlled. No WTF files or saved progress are edited during installation. Existing audit files describe earlier versions.
