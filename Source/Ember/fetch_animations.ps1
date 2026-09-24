$ErrorActionPreference='Stop'
$projectRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$destination=Join-Path $projectRoot '.tools/MeleeLib.res'
New-Item -ItemType Directory -Force (Split-Path $destination -Parent) | Out-Null
Invoke-WebRequest 'https://raw.githubusercontent.com/catprisbrey/Godot4-OpenAnimationLibraries/ccc61c4d8cdc1fb7188a60ba4f51f7a3cac51df9/Libraries/Humanoid/MeleeLib.res' -OutFile $destination
if ((Get-FileHash $destination -Algorithm SHA256).Hash -ne '7FA1B8EFB5AFDD962DA46F2B309CB5E4F3BD0886C5650C7C6BB91E04398BE8D6') { throw 'Animation library checksum mismatch' }
Write-Output 'Now run Godot --headless --path . --script res://Scripts/prepare_ember.gd'
