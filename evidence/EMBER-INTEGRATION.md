# Exercise 6 integrated into Exercise 5

Ember is the active player in the original Zombie Village Run campaign, using the existing two villages and published game URL.

- Blender source: `Source/Ember/Ember.blend`; playable scene: `Scenes/ember_player.tscn`.
- BoneMap remaps the assigned Melee library to the Blender rig. Four source clips provide Idle, Run, Jump, Flip and Hurt states. The original controller still owns movement, collision, double-jump flip, damage and respawn.
- Both local and release-checkout validators completed with **VALIDATION_OK**: Ember identity, 56 bones, five animation states, collision, double-jump cap, pause, checkpoint respawn, all eight collectibles in each level, both gates, victory and replay.
- Release export is built from committed source in an isolated checkout. Pre-existing local edits to `Scenes/village_dawn.tscn` are preserved locally and were not included in this release.
- Web export tested in Chromium: updated menu and Ember visibly present in the original first level; no runtime warning/error console entries.
- Historical acceptance evidence describes the earlier zombie version; this file records the Blender character integration.
