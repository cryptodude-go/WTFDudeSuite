# Installing WTF! DUDE SUITE 1.5

Close the game before installing this update: it adds new addon folders. Extract every folder from the ZIP directly into Interface/AddOns. Keep the existing DudeWheresMyDing folder name: it is now displayed as **WTF! DUDE - Core**, preserving settings and progress. Do not nest the folders inside a WTF-DUDE-SUITE-1.5 folder.

The ZIP contains Core and 12 optional folders named WTFDude_*. Keep Core enabled. In the character selection AddOns list, disable an optional entry to leave out that module. Its Settings tab disappears on the next load; deleting that optional folder has the same effect. Enabling a module requires its folder to be installed, Core enabled, and a reload/restart. An in-game module switch pauses a loaded module without removing its Settings tab.

Core provides shared UI, compatibility, quest/entity data and services used by several modules. Disabling a module prevents its optional implementation from loading, but shared Core code/data needed by other modules remains. All modules use the existing Core SavedVariables; none introduces a separate settings file. Module dependencies are only on Core, not on one another.

Settings → Chat & statistics → Quest messages / Level-up messages: edit each of ten templates, toggle random selection, leave an entry blank to exclude it, or restore defaults. Supported tokens: {quest}, {level}, {time}, {player}. Party/raid toggles control broadcasts. No message is sent merely by opening/editing settings.

Gathering retains possible-spawn circles, gathered-node history and routes. Live minimap scanning and resource discovery sounds are retired. A circle does not guarantee a spawned resource.

For rollback to v1.4, first remove the 12 WTFDude_* folders installed by this release, then restore the v1.4 DudeWheresMyDing folder from the backup. Do not delete WTF/SavedVariables.
