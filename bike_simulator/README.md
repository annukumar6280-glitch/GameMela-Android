# GameMela 3D Bike Simulator — first vertical slice

This folder is the first standalone Godot 4 3D game module for GameMela. It is deliberately separate from the Flutter shell while the Android embedding and account/garage hand-off are designed and tested.

## Prototype features
- Real-time 3D scene with a motorcycle and assembled rider model
- Procedural asphalt road, lane markings, roadside trees and houses
- Traffic vehicles, collision detection and restart
- Touch steering, accelerator and brake; keyboard controls for desktop testing
- Third-person chase camera and speed/distance HUD

## Controls
- Mobile: hold ◀ / ▶ to steer; hold ACCEL / BRAKE to control speed
- Desktop: WASD or arrow keys

## Current limitations
This is an initial playable 3D foundation, not the final release. Vehicle and environment meshes are procedural placeholders pending licensed production assets; engine/horn audio, gear selection, missions, detailed physics, device profiling, and Flutter/Supabase garage integration are not implemented yet. Do not distribute this prototype as the finished GameMela APK.
