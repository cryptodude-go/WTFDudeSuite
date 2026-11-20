# Gathering fixes · 0.15.1

- Removed the separate floating zone-map window, its switch, opacity slider, saved position and companion-map action. Old appearance values are discarded at addon initialization; gathering observations and guide progress are preserved.
- Gathering routes, node recording, the profession-page map preview, world-map circles and minimap circles remain available.
- Fixed the inverted vertical minimap-circle coordinate. North appeared below the player, causing pins to move against the terrain while walking or rotating.
- Updated minimap circles and circuit lines on each rendered frame rather than every half second. Profession scanning and route advancement remain throttled. Cached fixed node projections avoid repeating native node-coordinate lookups on each frame.
- Added indoor zoom fallback for clients without the native minimap-radius API. Out-of-range nodes are hidden rather than pushed to the map edge.
- Candidate ordering is independent of player movement. Circles indicate possible or historically gathered positions, not live spawns.

Validation: Lua 5.1 mocked-client checks cover removal of floating-map controls, fixed coordinates, next-frame movement, north/east placement, rotating minimap, zoom, native-coordinate caching, missing player position, hide/pause, skill-gated routing, harvesting, menus and repeated frame reuse. Existing standalone profession, reputation, Skyborne and smart quest routing regressions also run. A live-client visual check remains necessary; automated checks cannot verify the rendered terrain alignment on every Forever map.

Projection reference: [HereBeDragons minimap implementation](https://github.com/Nevcairiel/HereBeDragons/blob/master/HereBeDragons-Pins-2.0.lua), inspected for native radius and Classic indoor/outdoor zoom behavior. No external addon dependency was added.
