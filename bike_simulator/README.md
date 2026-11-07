# GameMela 3D Bike Simulator — first vertical slice

This folder contains the Godot 4.3 3D bike game module embedded in the existing Flutter GameMela Android app. The Android build exports this project as a PCK into the host app and launches it from the Garage through a native Android activity.

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
This is an initial playable 3D foundation, not the final release. Vehicle and environment meshes are procedural prototype geometry pending licensed production assets. Audio is synthesized placeholder sound, not real recorded engine/horn audio. Detailed motorcycle physics, wheel animation, missions beyond distance milestones, device profiling, real assets/audio, and deeper Supabase progression integration remain to be completed. The Garage's Ride Now button launches the embedded 3D game only for a bike already owned in the user's Garage; the Flutter host package ID, account, wallet, vehicle records, and AdMob configuration remain in the host app. Android CI now builds the integrated GameMela APK rather than a separate bike-only APK.
