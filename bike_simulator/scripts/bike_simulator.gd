extends Node3D

# GameMela first 3D vertical slice: a third-person motorcycle road simulator.
# All geometry is generated locally so the prototype has no missing asset dependencies.

const ROAD_LENGTH := 620.0
const ROAD_WIDTH := 14.0
const MAX_SPEED := 38.0
const ACCELERATION := 15.0
const BRAKING := 27.0

var speed := 0.0
var steer := 0.0
var distance := 0.0
var score := 0
var crashed := false
var throttle_touch := false
var brake_touch := false
var left_touch := false
var right_touch := false
var bike_root: Node3D
var bike_visual: Node3D
var camera: Camera3D
var speed_label: Label
var distance_label: Label
var status_label: Label
var road_marks: Array[MeshInstance3D] = []
var traffic: Array[Node3D] = []
var traffic_speeds: Array[float] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_build_world()
	_build_bike()
	_build_camera()
	_build_hud()
	_spawn_traffic(9)

func _process(delta: float) -> void:
	if crashed:
		return
	var throttle := throttle_touch or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var brake := brake_touch or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	var left := left_touch or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var right := right_touch or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	if throttle:
		speed = move_toward(speed, MAX_SPEED, ACCELERATION * delta)
	elif brake:
		speed = move_toward(speed, 0.0, BRAKING * delta)
	else:
		speed = move_toward(speed, 7.0, 3.0 * delta)
	steer = move_toward(steer, float(int(right) - int(left)), 3.2 * delta)
	bike_root.position.x = clampf(bike_root.position.x + steer * (2.9 + speed * 0.035) * delta, -5.4, 5.4)
	bike_visual.rotation.z = lerpf(bike_visual.rotation.z, -steer * 0.22, 7.0 * delta)
	distance += speed * delta
	_update_road(delta)
	_update_traffic(delta)
	_update_camera(delta)
	speed_label.text = "%03d km/h" % int(speed * 3.6)
	distance_label.text = "DISTANCE  %04d m" % int(distance)
	if bike_root.position.x < -4.7 or bike_root.position.x > 4.7:
		status_label.text = "KEEP TO THE ROAD"
	else:
		status_label.text = "RIDE SAFE  •  AVOID TRAFFIC"

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.78, 0.88)
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	add_child(sun)
	_add_box("Road", Vector3(ROAD_WIDTH, 0.18, ROAD_LENGTH), Vector3(0, -0.12, -ROAD_LENGTH * 0.46), Color(0.105, 0.12, 0.14))
	_add_box("Left shoulder", Vector3(2.0, 0.2, ROAD_LENGTH), Vector3(-8.0, -0.1, -ROAD_LENGTH * 0.46), Color(0.34, 0.31, 0.24))
	_add_box("Right shoulder", Vector3(2.0, 0.2, ROAD_LENGTH), Vector3(8.0, -0.1, -ROAD_LENGTH * 0.46), Color(0.34, 0.31, 0.24))
	_add_box("Left verge", Vector3(80, 0.25, ROAD_LENGTH), Vector3(-49, -0.22, -ROAD_LENGTH * 0.46), Color(0.20, 0.39, 0.19))
	_add_box("Right verge", Vector3(80, 0.25, ROAD_LENGTH), Vector3(49, -0.22, -ROAD_LENGTH * 0.46), Color(0.20, 0.39, 0.19))
	for side in [-1.0, 1.0]:
		_add_box("Road edge", Vector3(0.16, 0.025, ROAD_LENGTH), Vector3(side * 6.65, 0.0, -ROAD_LENGTH * 0.46), Color(0.94, 0.91, 0.78))
	for i in range(32):
		var mark := _add_box("Lane dash", Vector3(0.13, 0.025, 7.0), Vector3(0, 0.015, -i * 18.0), Color(0.95, 0.88, 0.58))
		road_marks.append(mark)
	for i in range(42):
		var z := -float(i) * 14.0 - 8.0
		for side in [-1.0, 1.0]:
			_build_tree(Vector3(side * rng.randf_range(13.0, 27.0), 0, z))
			if i % 3 == 0:
				_build_house(Vector3(side * rng.randf_range(28.0, 43.0), 0, z - 3.0))

func _build_tree(pos: Vector3) -> void:
	var tree := Node3D.new()
	tree.position = pos
	add_child(tree)
	_add_mesh(tree, CylinderMesh.new(), Vector3(0, 1.2, 0), Vector3(0.28, 1.2, 0.28), Color(0.28, 0.17, 0.09))
	_add_mesh(tree, SphereMesh.new(), Vector3(0, 3.0, 0), Vector3(1.5, 2.0, 1.5), Color(0.12, rng.randf_range(0.28, 0.42), 0.16))

func _build_house(pos: Vector3) -> void:
	var house := Node3D.new()
	house.position = pos
	add_child(house)
	var wall := Color(0.72, rng.randf_range(0.48, 0.68), 0.34)
	_add_mesh(house, BoxMesh.new(), Vector3(0, 1.5, 0), Vector3(7, 3, 6), wall)
	_add_mesh(house, BoxMesh.new(), Vector3(0, 3.35, 0), Vector3(7.8, 0.7, 6.8), Color(0.35, 0.16, 0.12))
	_add_mesh(house, BoxMesh.new(), Vector3(0, 1.5, -3.06), Vector3(1.0, 1.8, 0.12), Color(0.18, 0.36, 0.48))

func _build_bike() -> void:
	bike_root = Node3D.new()
	bike_root.position = Vector3(0, 0, 0)
	add_child(bike_root)
	bike_visual = Node3D.new()
	bike_root.add_child(bike_visual)
	var rubber := Color(0.025, 0.03, 0.035)
	var metal := Color(0.66, 0.70, 0.73)
	var red := Color(0.82, 0.045, 0.035)
	var black := Color(0.055, 0.065, 0.075)
	_add_mesh(bike_visual, CylinderMesh.new(), Vector3(0, 0.52, 1.0), Vector3(0.48, 0.19, 0.48), rubber, Vector3(0, 0, PI / 2))
	_add_mesh(bike_visual, CylinderMesh.new(), Vector3(0, 0.52, -1.05), Vector3(0.48, 0.19, 0.48), rubber, Vector3(0, 0, PI / 2))
	_add_mesh(bike_visual, CylinderMesh.new(), Vector3(0, 0.52, 1.0), Vector3(0.29, 0.205, 0.29), metal, Vector3(0, 0, PI / 2))
	_add_mesh(bike_visual, CylinderMesh.new(), Vector3(0, 0.52, -1.05), Vector3(0.29, 0.205, 0.29), metal, Vector3(0, 0, PI / 2))
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 0.91, 0.05), Vector3(0.22, 0.16, 1.75), metal, Vector3(0, 0, -0.12))
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 1.02, -0.38), Vector3(0.82, 0.38, 0.86), red)
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 1.19, -1.0), Vector3(0.62, 0.19, 0.55), black)
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 1.08, 0.65), Vector3(0.72, 0.16, 0.55), black)
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 1.46, -0.91), Vector3(0.48, 0.28, 0.28), red)
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 1.12, 1.15), Vector3(0.08, 0.75, 0.08), metal, Vector3(0.18, 0, 0))
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 1.72, 1.32), Vector3(1.05, 0.08, 0.12), metal)
	_add_mesh(bike_visual, SphereMesh.new(), Vector3(0, 1.52, 1.47), Vector3(0.24, 0.19, 0.16), Color(1.0, 0.92, 0.62))
	# Rider: jacket, helmet, arms and legs are separate shaded 3D forms.
	_add_mesh(bike_visual, CapsuleMesh.new(), Vector3(0, 2.02, -0.15), Vector3(0.48, 0.76, 0.42), Color(0.06, 0.16, 0.34), Vector3(0.32, 0, 0))
	_add_mesh(bike_visual, SphereMesh.new(), Vector3(0, 2.58, 0.18), Vector3(0.42, 0.42, 0.42), Color(0.92, 0.72, 0.52))
	_add_mesh(bike_visual, SphereMesh.new(), Vector3(0, 2.88, 0.2), Vector3(0.48, 0.42, 0.48), Color(0.92, 0.08, 0.035))
	for side in [-1.0, 1.0]:
		_add_mesh(bike_visual, CapsuleMesh.new(), Vector3(side * 0.32, 1.86, 0.57), Vector3(0.16, 0.72, 0.16), Color(0.08, 0.12, 0.2), Vector3(0.72, 0, side * 0.18))
		_add_mesh(bike_visual, CapsuleMesh.new(), Vector3(side * 0.25, 1.22, -0.02), Vector3(0.17, 0.7, 0.17), black, Vector3(0, 0, side * 0.48))
	_add_mesh(bike_visual, BoxMesh.new(), Vector3(0, 0.19, 1.0), Vector3(0.72, 0.12, 0.34), black)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 4.3, 8.8)
	camera.rotation_degrees = Vector3(-13, 0, 0)
	camera.fov = 72
	add_child(camera)
	camera.current = true

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0.025, 0.04, 0.07, 0.72)
	panel.position = Vector2(18, 16)
	panel.size = Vector2(260, 92)
	layer.add_child(panel)
	speed_label = Label.new()
	speed_label.position = Vector2(32, 20)
	speed_label.add_theme_font_size_override("font_size", 30)
	speed_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
	layer.add_child(speed_label)
	distance_label = Label.new()
	distance_label.position = Vector2(34, 62)
	distance_label.add_theme_font_size_override("font_size", 15)
	layer.add_child(distance_label)
	status_label = Label.new()
	status_label.anchor_left = 0.5
	status_label.anchor_right = 0.5
	status_label.offset_left = -210
	status_label.offset_right = 210
	status_label.offset_top = 18
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 17)
	layer.add_child(status_label)
	_add_control_button(layer, "◀", Vector2(28, -130), Vector2(90, 90), "left")
	_add_control_button(layer, "▶", Vector2(128, -130), Vector2(90, 90), "right")
	_add_control_button(layer, "BRAKE", Vector2(-220, -120), Vector2(100, 82), "brake")
	_add_control_button(layer, "ACCEL", Vector2(-110, -120), Vector2(100, 82), "throttle")

func _add_control_button(layer: CanvasLayer, caption: String, offset: Vector2, size: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = caption
	button.size = size
	button.anchor_left = 0.0 if action in ["left", "right"] else 1.0
	button.anchor_right = button.anchor_left
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_right = offset.x + size.x
	button.offset_top = offset.y
	button.offset_bottom = offset.y + size.y
	button.add_theme_font_size_override("font_size", 19)
	button.modulate = Color(1, 1, 1, 0.88)
	layer.add_child(button)
	button.button_down.connect(func(): _set_touch(action, true))
	button.button_up.connect(func(): _set_touch(action, false))

func _set_touch(action: String, value: bool) -> void:
	match action:
		"left": left_touch = value
		"right": right_touch = value
		"brake": brake_touch = value
		"throttle": throttle_touch = value

func _update_road(delta: float) -> void:
	var movement := maxf(speed, 4.0) * delta
	for mark in road_marks:
		mark.position.z += movement
		if mark.position.z > 12.0:
			mark.position.z -= 32.0 * 18.0

func _spawn_traffic(count: int) -> void:
	for i in range(count):
		var car := _make_traffic_car()
		car.position = Vector3([-4.2, 0.0, 4.2][i % 3], 0.0, -rng.randf_range(35.0, 500.0))
		add_child(car)
		traffic.append(car)
		traffic_speeds.append(rng.randf_range(4.0, 13.0))

func _make_traffic_car() -> Node3D:
	var car := Node3D.new()
	var paint := [Color(0.08, 0.28, 0.72), Color(0.72, 0.12, 0.06), Color(0.78, 0.76, 0.66), Color(0.08, 0.38, 0.28)][rng.randi_range(0, 3)]
	_add_mesh(car, BoxMesh.new(), Vector3(0, 0.72, 0), Vector3(1.8, 0.72, 3.2), paint)
	_add_mesh(car, BoxMesh.new(), Vector3(0, 1.28, -0.18), Vector3(1.48, 0.56, 1.55), Color(0.12, 0.2, 0.27))
	for x in [-0.68, 0.68]:
		for z in [-1.0, 1.0]:
			_add_mesh(car, CylinderMesh.new(), Vector3(x, 0.36, z), Vector3(0.32, 0.16, 0.32), Color(0.025, 0.025, 0.03), Vector3(0, 0, PI / 2))
	return car

func _update_traffic(delta: float) -> void:
	for i in range(traffic.size()):
		var car := traffic[i]
		car.position.z += (speed - traffic_speeds[i]) * delta
		if absf(car.position.z) < 2.5 and absf(car.position.x - bike_root.position.x) < 1.35:
			crashed = true
			speed = 0
			status_label.text = "CRASH!  TAP RESTART"
			_show_restart()
		if car.position.z > 18:
			car.position.z = -rng.randf_range(350.0, 560.0)
			car.position.x = [-4.2, 0.0, 4.2][rng.randi_range(0, 2)]

func _show_restart() -> void:
	var button := Button.new()
	button.text = "RESTART RIDE"
	button.size = Vector2(220, 72)
	button.position = Vector2(530, 310)
	button.add_theme_font_size_override("font_size", 22)
	get_child( get_child_count() - 1 ).add_child(button)
	button.pressed.connect(func(): get_tree().reload_current_scene())

func _update_camera(delta: float) -> void:
	var target := Vector3(bike_root.position.x * 0.42, 4.3, 8.8)
	camera.position = camera.position.lerp(target, 4.0 * delta)
	camera.look_at(Vector3(bike_root.position.x * 0.25, 1.2, -8.0), Vector3.UP)

func _add_box(label: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = box
	node.position = pos
	node.material_override = _material(color)
	add_child(node)
	return node

func _add_mesh(parent: Node3D, mesh: Mesh, pos: Vector3, scale: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.scale = scale
	node.rotation = rotation
	node.material_override = _material(color)
	parent.add_child(node)
	return node

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.28 if color.r > 0.5 else 0.08
	material.roughness = 0.48
	return material
