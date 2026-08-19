extends Node3D


@onready var rig: CameraRig = $CameraRig
@onready var cam: Camera3D = $CameraRig/Camera
@onready var label: Label3D = $Label3D


var is_backing_up: bool = false


func _ready() -> void:
	Conductor.beat.connect(_on_beat)

	Conductor.play_from_beat(0)


func _process(dt: float) -> void:
	if is_backing_up:
		cam.position.z += 0.5 * dt


func _on_beat(pos: int) -> void:
	print(pos)
	if pos == -1:
		rig.move_cam_to_next_marker(Conductor.TWO_BEAT)
	if pos == 1:
		# rig.move_cam_to_next_marker(Conductor.BEAT * 16.0)
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
