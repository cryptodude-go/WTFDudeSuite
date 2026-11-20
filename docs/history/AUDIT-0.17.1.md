# Navigation and settings fixes · 0.17.1

- Settings title bar supports dragging. Its position is stored in native account settings and retained when dialog scale changes.
- Legacy secure Target/Use Item buttons are hidden explicitly, including controls parented outside the old tracker. Changes to secure controls defer during combat.
- Local/inventory-only steps have no authored map destination. Navigation now falls back to nearby unfinished quest objectives, or the next available guide destination. Current-step destinations and explicit row-click navigation retain priority.
- Fallback destinations feed the existing animated minimap/world-map trail. Reaching one cannot complete an unrelated inventory instruction. Refreshing fallback selection is throttled to twice per second.
- Mocked Lua regression reproduces the inventory step and verifies a visible native arrow, actual minimap dots, destination priority, no unrelated step advancement, detached-control removal, drag callbacks and position retention through scale changes. Full native lifecycle/menu/guide/profession regressions also pass.

Installation updates addon code only; no WTF files are edited. Reload the UI to load this patch. Live in-game visual verification remains with the player.
