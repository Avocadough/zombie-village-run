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

## Engine

Godot Engine 4.7.2 stable (MIT).
https://godotengine.org/license/
https://godotengine.org/download/archive/4.7.2-stable/

Third-party assets retain their respective licenses; LICENSE.md does not override their terms.
