# Asset credits

## Starter project

3D Platformer Starter Kit by Silver Demon Studios (SD Studios).
Original project: https://github.com/SilverDemons-PK/3D-Platformer-Kit
Assignment reference: https://store.godotengine.org/asset/the-silver-demons/platformer-3d-starter-kit/
License: MIT; original copyright and full license retained in LICENSE.md.
The original Scenes/player.tscn and Scripts/player.gd remain in the source project.
Scripts/zombie_player.gd derives movement, model-facing and double-jump concepts from the starter controller, moves physics to _physics_process, and fixes the delayed jump-limit reset.
The original jump and pickup sounds and AudioManager are reused.

## Player model

Zombie by bachosoftdesign, from Poly Pizza:
https://poly.pizza/m/xqEzosAVYX
License shown by the asset page: Creative Commons Attribution.
The model was supplied in the assignment workspace as `Zombie by bachosoftdesign - xqEzosAVYX.glb`.
Changes: runtime scale normalization, animation aliases, faster Walk playback for Run, and procedural airborne tilt/flip around the character's local X axis.
Idle maps to Armature|Idle; Run maps to Armature|Walk at 1.8x; Hurt maps to Armature|Hit_reaction. Jump and Flip reuse the skeleton's Idle pose while the visual root is animated procedurally. These are adapted states, not newly motion-captured skeletal clips.

## Environment

Medieval Village Pack by Quaternius, from Poly Pizza:
https://poly.pizza/bundle/Medieval-Village-Pack-NsHhjhlrfY
License: CC0 / Public Domain.
https://creativecommons.org/publicdomain/zero/1.0/
The archive was supplied in the workspace. Models used include Fantasy House, Market Stand, Crate, Barrel, and Bell Tower. Scales, placement and rotation adapted for this game.

Ground islands, trees, golden shards, gates and traps are made from Godot primitive meshes.

## Exercise 6 player: Ember

Original model and 56-bone armature created in Blender from basic primitives; editable source is `Source/Ember/Ember.blend`. The rig was authored in Blender, not uploaded to Mixamo auto-rig. It follows Godot's Humanoid Profile rest axes and the provided Mixamo BoneMap.

Melee animations and BoneMap: https://github.com/catprisbrey/Godot4-OpenAnimationLibraries at revision `ccc61c4d8cdc1fb7188a60ba4f51f7a3cac51df9`, as required by Exercise 6. Four source clips supply Idle, Run, Jump, Flip and Hurt states. Physics supplies airborne movement and the second-jump visual flip; airborne position tracks are omitted to avoid moving twice.

These third-party animations are not claimed as original or MIT-licensed. Standalone animation resources are downloaded from upstream during source setup; the Web application embeds the selected clips for gameplay. Upstream's FORMER-README discusses animation-dataset redistribution, so this repository is not a standalone animation library.

## Engine runtime

Godot Engine 4.7.2 stable (MIT).
https://godotengine.org/license/
https://godotengine.org/download/archive/4.7.2-stable/

Third-party assets retain their respective licenses; LICENSE.md does not override their terms.

