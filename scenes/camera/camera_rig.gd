@tool
class_name CameraRig extends Node3D


@onready var cam: Camera = $Camera


var markers: Array[Marker3D] = []
var curr_marker_idx: int = 0
var cam_tween: Tween


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	for child in get_children():
		if child is Marker3D:
			markers.append(child)

	move_cam_to_next_marker(0)


func move_cam_to_next_marker(duration: float, trans: Tween.TransitionType = Tween.TRANS_EXPO, ease: Tween.EaseType = Tween.EASE_OUT) -> void:
	var next_marker := get_marker(curr_marker_idx)
	if next_marker:
		# if cam_tween: cam_tween.kill()
		cam_tween = create_tween().set_parallel()
		curr_marker_idx += 1
		cam_tween.tween_property(cam, "global_transform", next_marker.global_transform, duration).set_trans(trans).set_ease(ease)
	else:
		print("no more markers for camera to move to")


func create_marker(tf: Transform3D) -> void:
	var marker := Marker3D.new()
	marker.name = "Marker#" + str(get_marker_count())
	marker.transform = tf
	marker.add_to_group("camera_rig")
	add_child(marker)
	marker.owner = get_tree().edited_scene_root


func clear_markers() -> void:
	# for marker in markers:
	# 	marker.queue_free()
	# markers.clear()
	for child in get_children():
		if child.is_in_group("camera_rig"):
			child.queue_free()


func get_marker_count() -> int:
	var count := 0
	for child in get_children():
		if child is Marker3D:
			count += 1
	return count

func get_marker(idx: int) -> Marker3D:
	return markers[idx] if idx < markers.size() else null
