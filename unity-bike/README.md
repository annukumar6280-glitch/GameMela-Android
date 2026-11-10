# GameMela 3D Games — Unity runtime foundation

This Unity runtime is being developed for the existing Android Flutter app. The intended game lineup is six modes:

1. Bike Racing — first development priority
2. Car Racing
3. Train Simulator
4. Plane Simulator
5. 3D Endless Runner
6. 3D Stunt Challenge

## App architecture

Flutter remains the app shell for authentication, Supabase account/wallet, garage, navigation and rewarded-ad flows. Unity owns real-time 3D scenes, vehicle/character physics, cameras, mobile controls and game audio. Stable mode identifiers live in `Assets/GameMela/Runtime/GameModeId.cs`.

Do not reset or replace the existing Supabase project, users, coin balances, Android application ID, package identity or Play signing configuration.

## Gameplay source currently committed

- Bike: WheelCollider motorcycle controller, mobile input bridge and follow camera in `Assets/GameMelaBike/Scripts`.
- Car: dedicated four-wheel WheelCollider controller in `Assets/GameMela/Runtime/Car`.
- Train: track-forward movement, throttle and service brake in `Assets/GameMela/Runtime/Train`.
- Plane: thrust, speed-limited flight, lift and pitch/roll/yaw input in `Assets/GameMela/Runtime/Plane`.
- Endless Runner: three-lane movement, jump and gravity in `Assets/GameMela/Runtime/Runner`.
- Stunt Challenge: airborne bike rotation and hard-landing feedback in `Assets/GameMela/Runtime/Stunt`.

These are separate gameplay foundations, not six finished games. They require proper prefabs, scene wiring, control HUDs, collision layers, sound, progression and extensive tuning.

## Art and scene requirements

No colored-cube or flat-sprite substitute is acceptable for the final experience. Each game needs licensed/commissioned production 3D models, PBR materials, rigging/animation, lighting, effects, environment art and optimized LODs.

- Bike: recognizable motorcycle, seated rider, curved/elevated roads, traffic, houses, trees, petrol station, garage and engine/horn audio.
- Car: visibly distinct car models, four-wheel suspension, city/highway circuits, traffic, barriers and vehicle audio.
- Train: locomotive, carriages, rails, switches, stations/platforms, passenger characters and station ambience.
- Plane: aircraft, cockpit, runway, airport, flight camera, takeoff/landing zones and aircraft audio.
- Runner: animated character, multiple obstacle sets, pickups, biomes and responsive lane/jump/slide controls.
- Stunt: distinct bike/rider, ramps, stunt arena, trick scoring, landing zones and impact feedback.

## Android integration and quality gates

1. Open and validate the Unity project with a supported Unity 6 editor and Android Build Support.
2. Build each scene independently and profile on lower/mid-range Android hardware.
3. Integrate Unity as a Library into Flutter only after standalone Android validation.
4. Connect garage ownership, repairs, upgrades (up to 50 levels), progress and wallet through authenticated, server-validated interfaces. Never trust client-only coin deductions.
5. Verify touch controls, audio, pause/resume, lifecycle, thermal performance and frame pacing on physical devices.
6. Produce and install a signed test APK, then verify Play-compatible AAB output and update path.

## Current honest status

The repository contains controller foundations and the architecture for all six modes. Production art, finished scenes, full Flutter-to-Unity bridge, backend progression integration, Unity Android export, APK/AAB and physical-device QA are **not complete**. No build is represented as playable or test-ready until those gates pass.
