#!/usr/bin/env python3
"""Wire the Godot 3D bike pack into the Flutter Android host app."""
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(".")
gradle = root / "android/app/build.gradle.kts"
text = gradle.read_text()
dependency = 'implementation("org.godotengine:godot:4.3.0.stable")'
if dependency not in text:
    if "dependencies {" not in text:
        raise SystemExit("Could not find dependencies block in app/build.gradle.kts")
    text = text.replace("dependencies {", "dependencies {\n    " + dependency, 1)
    gradle.write_text(text)

main_files = list((root / "android/app/src/main/kotlin").rglob("MainActivity.kt"))
if len(main_files) != 1:
    raise SystemExit(f"Expected one Flutter MainActivity.kt, found {len(main_files)}")
main_file = main_files[0]
package_line = next((line for line in main_file.read_text().splitlines() if line.startswith("package ")), None)
if not package_line:
    raise SystemExit("Flutter MainActivity.kt has no package declaration")
package_name = package_line.split(maxsplit=1)[1]
main_file.write_text(f'''{package_line}

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {{
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {{
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gamemela/bike_simulator")
            .setMethodCallHandler {{ call, result ->
                if (call.method == "launchBikeSimulator") {{
                    startActivity(Intent(this, BikeSimulatorActivity::class.java))
                    result.success(null)
                }} else {{
                    result.notImplemented()
                }}
            }}
    }}
}}
''')

bike_activity = main_file.parent / "BikeSimulatorActivity.kt"
bike_activity.write_text(f'''package {package_name}

import org.godotengine.godot.GodotActivity

class BikeSimulatorActivity : GodotActivity() {{
    override fun getCommandLine(): MutableList<String> {{
        val args = super.getCommandLine().toMutableList()
        args.add("--main-pack")
        args.add("bike_simulator.pck")
        return args
    }}
}}
''')

manifest = root / "android/app/src/main/AndroidManifest.xml"
android_ns = "http://schemas.android.com/apk/res/android"
ET.register_namespace("android", android_ns)
tree = ET.parse(manifest)
app = tree.getroot().find("application")
if app is None:
    raise SystemExit("Android manifest has no application element")
activity_name = ".BikeSimulatorActivity"
if not any(a.tag == "activity" and a.get(f"{{{android_ns}}}name") == activity_name for a in app):
    ET.SubElement(app, "activity", {
        f"{{{android_ns}}}name": activity_name,
        f"{{{android_ns}}}exported": "false",
        f"{{{android_ns}}}screenOrientation": "landscape",
        f"{{{android_ns}}}configChanges": "orientation|screenSize|smallestScreenSize|screenLayout|keyboardHidden",
        f"{{{android_ns}}}theme": "@android:style/Theme.Black.NoTitleBar.Fullscreen",
    })
tree.write(manifest, encoding="utf-8", xml_declaration=True)
ET.parse(manifest)

pck = root / "android/app/src/main/assets/bike_simulator.pck"
if not pck.is_file() or pck.stat().st_size == 0:
    raise SystemExit("Godot PCK was not exported into Android app assets")
print(f"Godot embedding configured for {package_name}; PCK size={pck.stat().st_size} bytes")
