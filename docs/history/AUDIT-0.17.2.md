# Directory, arrow dragging and continuous navigation · 0.17.2

- Directory title bar supports direct dragging, with a separate persisted position retained through dialog-scale changes.
- Waypoint arrow supports direct left-button dragging. Its position is stored as a normalized CENTER anchor. Navigation rendering pauses while dragging and resumes after release.
- Root cause of intermittent fallback guidance: the arrow driver clears its cached position periodically, but the temporary candidates from the bridge had already been restored to an empty list. Nearest-point lookup now retains the fallback candidates across those driver ticks. Explicit targets and current guide destinations still take priority.
- Animated route segments shorter than the dot spacing keep at least one visible dot throughout the animation; phase wrapping no longer leaves them empty for part of the cycle.
- Regression: 100 forced driver refreshes retained waypoint/arrow/trail without a fade-out; 201 short-line animation phases all rendered visible dots; direct arrow and Directory drag callbacks saved positions and retained them across position/scale updates. Existing full native menu, guide, profession, settings dragging, detached-controls and navigation regressions passed.

Code-only installation; existing saved data and WTF files are not edited. Reload the UI after updating. Automated mocked-client checks are not live WoW visual sign-off.
