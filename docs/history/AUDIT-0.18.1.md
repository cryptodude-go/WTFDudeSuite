# Settings and live-node patch · 0.18.1

Shared dropdown focus no longer cancels a popup when obscured controls receive mouse-enter events. Explicit outside clicks and normal selection/back/close retain dismissal. The live status timer refreshes only its status label.

The scanner no longer requires C_Minimap.GetTrackingInfo.spellID: the Forever-generated Minimap documentation marks it optional. Real minimap tooltips remain the evidence of node presence. Name normalization accepts leading symbols, texture/atlas decoration and nonbreaking spaces, while requiring an exact resource name. Profession/skill filtering remains. Each successful probe batch can publish its target immediately rather than waiting for a complete scan. Too-low skill and API failure reasons are visible in Gathering status.

Validation: work/test_live_gather0181.py runs the full native/lifecycle/navigation/scrollbar and live-gather regression suite, then opens all 8 dropdowns across top-level and nested pages, simulates obscured-row hover, repeated refresh and actual item selection, and verifies explicit dismissal. Synthetic live dots verify missing tracking IDs, decorated and localized mining names, first-batch sound/arrow/line, rejected creature names and too-hard ore. No live game session was controlled or verified. Earlier audit documents describe their respective releases.

No saved-variable/WTF files are modified. Existing preferences and progress are preserved.
