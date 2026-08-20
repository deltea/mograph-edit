extends Node3D


const work_scene := preload("res://scenes/work/work.tscn")
const icons_path := "res://assets/icons/"
const colors := ["#fc7f7f", "#8da5f3", "#8da5f3", "#ffca5f", "#e0e0e0"]


@export var drop_pattern: Array[bool] = []


@onready var rig: CameraRig = $CameraRig
@onready var cam: Camera3D = $CameraRig/Camera
@onready var label: Label3D = $Label3D
@onready var flashbang: ColorRect = $CanvasLayer/Base/Flashbang
@onready var grid: GridContainer = $CanvasLayer/Base/GridContainer
@onready var base: Control = $CanvasLayer/Base


var is_backing_up: bool = false
var cam_vel: float = 1.0
var cam_accel: float = 0.3
var icons: Array[Texture2D] = []

var icon_idx: int = 0


func _ready() -> void:
	var dir := DirAccess.open(icons_path)
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
			icons.append(load(icons_path + file_name))
	dir.list_dir_end()
	icons.shuffle()

	clear_drop()

	Conductor.beat.connect(_on_beat)
	Conductor.play_from_beat(0)


func _process(dt: float) -> void:
	if is_backing_up:
		cam.position.z += cam_vel * dt

	cam_vel += cam_accel * dt
	cam_accel += 0.1 * dt

	base.position = base.position.lerp(Vector2.ZERO, 20.0 * dt)


func _on_beat(pos: int) -> void:
	# print(pos)
	if pos == -1:
		rig.move_cam_to_next_marker(Conductor.TWO_BEAT)

	if pos == 1:
		is_backing_up = true

	if pos == -1:
		await Conductor.wait(Conductor.BEAT)
		var words := ["GET", "IT", "POPPIN'", "PUT", "IN"]
		var tween := create_tween()
		for i in range(words.size()):
			tween.tween_callback(func() -> void:
				label.text += words[i] + " "
			)
			tween.tween_interval(Conductor.BEAT / words.size())

	if pos >= 1:
		await Conductor.wait(Conductor.HALF_BEAT)
		var work := work_scene.instantiate() as Sprite3D
		add_child(work)
		work.texture = icons[icon_idx]
		work.position = cam.global_position + cam.global_transform.basis.z * -1.0
		var rand_rot := randf_range(-60, 60) * (-1 if pos % 2 == 0 else 1)
		var rand_pos_rot := deg_to_rad(randf_range(0, 360))
		work.rotation_degrees.z = 0
		var unit_circle := Vector2(cos(rand_pos_rot), sin(rand_pos_rot))
		work.position.x += unit_circle.x
		work.position.y += unit_circle.y
		work.scale = Vector3.ONE * 3.0
		var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(work, "scale", Vector3.ONE * 1.5, Conductor.BEAT).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(work, "rotation_degrees:z", rand_rot, Conductor.BEAT * 1.5).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(cam, "rotation_degrees:z", 4 * (1 if pos % 2 == 0 else -1), Conductor.BEAT)

		icon_idx = (icon_idx + 1) % icons.size()

	if pos == 24:
		var tween := create_tween()
		tween.tween_property(flashbang, "color:a", 1.0, Conductor.MEASURE * 2 - Conductor.TWO_BEAT)

	if pos == 33 or pos == 41:
		clear_drop()
		var tween := create_tween().set_parallel()
		var beat_num := 0
		for i in range(drop_pattern.size()):
			if drop_pattern[i]:
				tween.tween_callback(func() -> void: drop_beat(beat_num)).set_delay(i * Conductor.QUARTER_BEAT)
				beat_num += 1


func clear_drop() -> void:
	for child in grid.get_children():
		child.self_modulate.a = 0.0


func drop_beat(num: int) -> void:
	flashbang.color = Color(colors[num % colors.size()])
	grid.get_child(num).self_modulate.a = 1.0
	base.position.y = 48.0
