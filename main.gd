extends Node3D


const work_scene := preload("res://scenes/work/work.tscn")


@onready var rig: CameraRig = $CameraRig
@onready var cam: Camera3D = $CameraRig/Camera
@onready var label: Label3D = $Label3D
@onready var flashbang: ColorRect = $CanvasLayer/Flashbang


var is_backing_up: bool = false
var cam_vel: float = 0.0
var cam_accel: float = 0.5


func _ready() -> void:
	Conductor.beat.connect(_on_beat)

	Conductor.play_from_beat(0)


func _process(dt: float) -> void:
	if is_backing_up:
		cam.position.z += cam_vel * dt

	cam_vel += cam_accel * dt
	cam_accel += 0.2 * dt


func _on_beat(pos: int) -> void:
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
		var work := work_scene.instantiate() as Node3D
		add_child(work)
		work.position = cam.global_position + cam.global_transform.basis.z * -1.0
		var rand_rot := randf_range(-60, 60) * (-1 if pos % 2 == 0 else 1)
		var rand_pos_rot := deg_to_rad(randf_range(0, 360))
		work.rotation_degrees.z = 0
		var unit_circle := Vector2(cos(rand_pos_rot), sin(rand_pos_rot))
		work.position.x += unit_circle.x
		work.position.y += unit_circle.y
		work.scale = Vector3.ZERO
		var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(work, "scale", Vector3.ONE, Conductor.BEAT).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(work, "rotation_degrees:z", rand_rot, Conductor.BEAT).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(cam, "rotation_degrees:z", 10 * (1 if pos % 2 == 0 else -1), Conductor.BEAT)

	if pos == 24:
		var tween := create_tween()
		tween.tween_property(flashbang, "color:a", 1.0, Conductor.MEASURE * 2)
