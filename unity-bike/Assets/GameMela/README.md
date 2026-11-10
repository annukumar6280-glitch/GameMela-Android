# GameMela Unity 3D runtime

This is the Unity-side gameplay source area for the Android Flutter app. The intended six modes are:

1. Bike Racing
2. Car Racing
3. Train Simulator
4. Plane Simulator
5. 3D Endless Runner
6. 3D Stunt Challenge

## Architecture

Flutter remains responsible for authentication, account, Supabase wallet, garage UI, navigation and rewarded-ad flows. Unity owns real-time 3D scenes, physics, cameras, touch input and game audio. Game mode IDs in `Assets/GameMela/Runtime/GameModeId.cs` are stable identifiers for the eventual Flutter-to-Unity bridge.

## Per-mode foundations

- Bike Racing: WheelCollider motorcycle physics, touch-input bridge and follow camera in `Assets/GameMelaBike/Scripts`.
- Car Racing: use a separate four-wheel vehicle prefab and car-specific WheelCollider controller; do not reuse the motorcycle visual or handling.
- Train Simulator: `TrainDriveController` constrains movement to a track-forward reference and provides throttle/brake hooks.
- Plane Simulator: `PlaneFlightController` provides thrust, lift and three-axis control hooks.
- Endless Runner: `EndlessRunnerController` provides three-lane movement, jump and gravity.
- Stunt Challenge: `StuntBikeAirController` provides airborne rotation and hard-landing feedback.

## Required production content (not included yet)

These scripts are gameplay foundations, not completed games. Each mode still needs authored Unity scenes, production-quality licensed 3D models/rigs/animations, materials, lighting, environment art, audio, collision/track design, mobile HUD, progression, QA and Android performance testing. Train needs locomotive/carriage/rail/station/passenger assets; plane needs aircraft/cockpit/runway/airport assets; runner needs character/obstacle/biome sets; stunt needs bike/rider/ramp/arena sets. The bike and car need distinct realistic vehicles and riders/drivers.

## Integration and release safeguards

- Do not change the existing Android application ID, Supabase project, user records, wallet balances or signing setup.
- Integrate Unity as a Library only after the Unity project builds independently on Android.
- Keep Android release output AAB-capable and preserve version-code progression.
- No game is declared test-ready until it has a real scene and assets, touch controls/audio, Android build, and physical-device QA. No APK/AAB is claimed by this source scaffold.
