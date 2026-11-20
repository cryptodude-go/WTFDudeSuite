# WTF! DUDE SUITE 1.4

- Herb/mining and Lockpicking minimap circles refresh at 10 Hz rather than every rendered frame.
- Optional gathering, Lockpicking, rare, marking and gear drivers sleep when unused/disabled; spam native-ignore worker sleeps with an empty queue. A one-second controller wakes newly needed work; Suite switches apply immediately.
- Gear overlays refresh when content, equipment, settings or window visibility changes, instead of repeatedly rescoring unchanged windows.
- Live node scans retain a 48-probe / 1 ms batch ceiling, capped at 40 batches/sec; existing alerts, sounds, detours and combat guards remain. Reuse minimap sampling grid and localized node-name lookup.
- Timer render refresh is 4 Hz while active and 1 Hz while idle; flight/transport learning and arrival logic remain independent.
- Portrait docking polls while dragging; ordinary updates use the existing level/portrait/panel events.
- Skip 1,547 inactive-language guide translation tables before constructing them; keep all languages and guide coverage.
- Reuse Sparkles, gathering-skill and Lockpicking settings page frames across repeated visits.
- Bound gathering map-node cache to eight entries; stop repeated legacy UI cleanup unless detached old action buttons reappear.
- Rare unit-health events remove only confirmed dead tracked units; periodic/event discovery remains.
- Settings → Suite options → Performance snapshot, or /wtf performance: on-demand RAM and available cumulative CPU readings. No background profiling, automatic profiler enabling or forced garbage collection.
