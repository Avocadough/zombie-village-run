# Zombie Village Run

A two-level low-poly 3D platformer for Exercise 5 First 3D Game, built with **Godot 4.7.2** from the supplied SD Studios starter project.

[Play the browser demo](https://avocadough.github.io/zombie-village-run/) · [Credits](CREDITS.md) · [Acceptance evidence](evidence/ACCEPTANCE.md)


## Exercise 6 — Blender character in the original game

**Ember is now the playable character in both existing villages.** The original Blender model and humanoid rig replace the earlier zombie player, with real Mixamo Melee Idle, Sprint, Jump and Hurt animations. The second jump retains the original controller's full-body flip. Movement, collisions, collectibles, checkpoints and two-stage progression stay in the original game.

Editable Blender source: `Source/Ember/Ember.blend`. Active player scene: `Scenes/ember_player.tscn`. The earlier zombie scene is retained as the Exercise 5 version.

Before running a fresh clone, execute `powershell -File Source/Ember/fetch_animations.ps1`, then `godot --headless --path . --script res://Scripts/prepare_ember.gd` (use your installed Godot executable path). This downloads the assignment's pinned upstream Melee library and prepares only the four source clips needed by the game. The public Web build is ready to play without these steps.

## How to play

- WASD or arrow keys: move.
- Space: jump; press again in the air to double jump.
- Esc / P or the Pause button: pause and resume.
- R: restart the current level (resets that level's shards).
- Collect all 8 golden shards in each village, avoid red moving spikes and gaps, then enter the gate.
- A checkpoint halfway through each level saves your respawn position. Damage preserves collected shards.

Village Dawn introduces the path, gaps and moving spikes. Moonlit Keep changes the atmosphere, increases spike speed and adds fire hazards at the gaps. Finish both levels to win.

## Open and export

Import `project.godot` with Godot 4.7.2. Main scene: `Scenes/main.tscn`.
The two stage resources are `Scenes/village_dawn.tscn` and `Scenes/moonlit_keep.tscn`; their geometry is saved as editable scene nodes. `Scripts/village_level.gd` connects gameplay events at runtime. `Scenes/ember_player.tscn` is the active player; `Scripts/ember_player.gd` maps Melee tracks through the supplied Mixamo BoneMap.
Install the matching Web export templates, then export the `Web` preset to `docs/index.html`.
The Web preset uses Compatibility rendering and disables threads for GitHub Pages.

```powershell
godot --headless --path . --export-release Web docs/index.html
godot --headless --path . --scene res://Scenes/validate.tscn
```

GitHub Pages serves the committed `/docs` directory on `main`. Re-export and push that directory when changing the game. Serve the files over HTTP; opening the HTML directly from disk does not load WebAssembly correctly.

## Project map

| Path | Contents |
| --- | --- |
| [project.godot](project.godot), [Scenes/](Scenes/) | Godot project, the two levels and player scenes |
| [Scripts/](Scripts/) | Player, stage and preparation scripts |
| [Source/Ember/](Source/Ember/) | Editable Blender character and animation-fetch script |
| [docs/](docs/), [evidence/](evidence/) | Web export and recorded project checks |

## Assignment coverage

| Requirement | Implementation |
| --- | --- |
| At least two 3D scenes | Village Dawn and Moonlit Keep |
| Starter kit basis | Supplied starter retained; movement derivative and starter sound manager |
| Replace player from Poly Pizza | Zombie by bachosoftdesign |
| Adapt animations | Idle, Run, Jump, Flip, Hurt adapter; see credits for exact mapping |
| Collect all items before next stage | 8 per level, locked exit gate |
| Traps and obstacles | Moving spikes, gaps, solid crate obstacles, second-level fire |
| Low-poly environment | Quaternius Medieval Village Pack and primitive geometry |
| Browser build | Godot Web export hosted on GitHub Pages |

## Verification and limitations

See [acceptance evidence](evidence/ACCEPTANCE.md) and the repeatable validator. Both stages are traversed using actual input and physics, rather than teleporting through the completion test.
Desktop keyboard and landscape view are recommended. Touch controls and persistent saves are outside this version. The initial WebAssembly engine download is about 40 MB, plus game data.

See [CREDITS.md](CREDITS.md) for attribution and licensing. The supplied exercise DOCX and original ZIP archives remain local and are not part of the public repository.

