# Acceptance checks

Target: Exercise 5 First 3D Game. Engine: Godot 4.7.2 stable official ed1daf0bf.

The repeatable validator is Scenes/validate.tscn. It uses physics frames, input actions, real collision bodies and Area3D overlaps to traverse both levels, with isolated direct calls for the gate-lock and damage unit checks.

- Menu blocks player movement.
- Player stands on collision geometry.
- Idle, Run, Jump, Flip and Hurt animation states exist.
- Exit does not advance with missing shards.
- Third airborne jump is rejected.
- Pause freezes the timer.
- Damage respawns at the current checkpoint.
- The input-driven route collects 8 shards and reaches the exit in each level.
- Checkpoint activates through overlap in each level.
- Both levels lead to the victory screen.
- Replay resets level, shard count and respawn count.

Run from the project directory:

```powershell
& 'PATH/TO/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --scene res://Scenes/validate.tscn
```

Expected final line: VALIDATION_OK, exit code 0.

Browser QA uses the actual exported WebAssembly build. Visual inspection covers menu, visible collectible placement, player, scene lighting and pause interface. Automated route proof is native Godot physics, not a claim that a human tester manually completed every browser path.

Limits: keyboard controls; desktop landscape viewport recommended. Mobile touch controls are not implemented. Progress is session-only. No cross-browser performance guarantee.
