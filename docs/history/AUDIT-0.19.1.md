# Equipment restrictions · 0.19.1

Root cause: Gear.CanWear accepted all cloth/miscellaneous armor before checking class restrictions. Thus a druid could receive a mage-only cloth upgrade, including the beta Arcanist Belt (item 288830) shown by the user.

Compat.EquipmentAllowed reads the live tooltip through C_TooltipInfo, with a private hidden-tooltip fallback. It recognizes the client’s ITEM_CLASSES_ALLOWED format, colored/localized names, male/female class labels and multi-class lists. The native equippability flag can reject an item too, but an affirmative flag cannot bypass the tooltip class restriction. Checks use a one-second item/class/level cache; missing or unreadable data defers suggestions and requests item data with throttling. Item data events clear the cache and schedule a fresh scan. No static Classic item IDs are required for custom beta items.

Gear.CanWear now requires loaded metadata and successful restriction validation before armor/weapon rules. Unknown types are deferred. Suggested gear and automatic equip revalidate restrictions; auto-equip checks current bag identity. Gain/Compare and quest reward upgrade ranking share the same guard. Restricted reward items can still be chosen explicitly for vendor value when no usable choice is available, never labeled an upgrade. Druid idols/paladin librams/shaman totems are included in their class armor mappings.

Validation: work/test_gear0191.py runs the entire v0.19 regression chain plus 81 combinations of nine wearer classes and nine class owners. The reported custom Arcanist Belt is rejected for druids, accepted for mages. Tests cover multi-class and female/localized labels, exact matching, ordinary unrestricted cloth, armor/relic compatibility, unknown/loading data and retry, stale suggestions, bag scan, quest rewards and automatic equip/bag identity. All Lua sources compile in Lua 5.1; package/install hashes verified. These are simulated-client tests, not live in-game verification.

No WTF files or saved progress are modified. No additional module files are needed by the patch; /reload is sufficient from v0.19.0.
