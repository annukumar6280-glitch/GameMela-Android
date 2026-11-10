# GameMela 3D Bike Racing — Unity foundation

This folder is the first Unity game module for the existing GameMela Android app.

## Product direction

Build the bike game first as a polished, third-person 3D riding experience:
- rider visibly seated on a proper motorcycle model (not a box or a flat sprite)
- detailed road with bends, roadside buildings, trees, petrol station and environmental props
- responsive touch steering, throttle, brake and horn
- engine and horn audio, follow camera, bike lean and wheel physics
- garage-owned bike models, repairs and 50 upgrade levels connected to the existing Supabase account/wallet

## Integration decision

Keep the existing Flutter application as the app shell for authentication, wallet, garage and navigation. Build the ride experience in Unity and integrate it as an Android Unity module after the Unity scene and asset pipeline are validated. Do not replace or reset the existing Supabase project, user accounts, wallet balances, application identity or Play signing configuration.

## Unity project setup

Create/open this folder as a Unity 6 project and install Universal Render Pipeline (URP), Input System and Cinemachine for the production camera rig.

The C# scripts in `Assets/GameMelaBike/Scripts` are the gameplay foundation. Create the scene and assign production assets/prefabs in the Inspector:
1. Motorcycle prefab with Rigidbody, front/rear WheelColliders and visual wheel meshes.
2. Seated, rigged rider model.
3. Road/environment prefabs and colliders.
4. Engine and horn audio clips.
5. Mobile HUD buttons wired to `BikeMobileInput`.

The controller requires assigned wheel colliders and real prefabs; it does not generate primitive box vehicles as visual substitutes.

## Quality gates before calling the bike game test-ready

- Rider is visibly seated and animated on a recognizable motorcycle.
- Road has curves, elevation variation, collision boundaries and readable roadside scenery.
- Steering, acceleration, braking, lean, horn and engine audio work on a real Android phone.
- Stable frame pacing on a lower-mid-range Android device; scalable URP quality settings.
- Garage selection, repair and upgrades are persisted without changing existing account or coin data.
- Test APK is built and installed successfully; only then proceed to the other game modes.

## Current status

Foundation scripts and integration requirements only. A finished playable 3D game, production art assets, Unity export, APK/AAB and device testing are **not** claimed by this commit.
