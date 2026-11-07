# GameMela 3D Bike Simulator — first vertical slice

This folder is the first standalone Godot 4 3D game module for GameMela. It is deliberately separate from the Flutter shell while the Android embedding and account/garage hand-off are designed and tested.

## Prototype features
- Real-time 3D scene with a motorcycle and assembled rider model
- Procedural asphalt road, lane markings, roadside trees and houses
- Traffic vehicles, collision detection and restart
- Touch steering, accelerator, brake and five selectable gears; keyboard controls for desktop testing
- Third-person chase camera and first-person camera toggle
- Generated engine-tone loop and horn effect (temporary synthesized audio, not recorded motorcycle audio)
- 500 m distance milestones and speed/gear HUD

## Controls
- Mobile: hold ◀ / ▶ to steer; hold ACCEL / BRAKE to control speed
- Desktop: WASD or arrow keys

## Current limitations
This is an initial playable 3D foundation, not the final release. Vehicle and environment meshes are procedural prototype geometry pending licensed production assets. Audio is synthesized placeholder sound, not real recorded engine/horn audio. Detailed motorcycle physics, wheel animation, missions beyond distance milestones, device profiling, and Flutter/Supabase garage integration remain to be completed. The Android APK built by CI is a standalone prototype for testing and is not yet the integrated GameMela release. Do not distribute this prototype as the finished GameMela APK.
