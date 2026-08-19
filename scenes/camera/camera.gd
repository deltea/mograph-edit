@tool
class_name Camera extends Camera3D


@export_tool_button("Create Marker", "Marker3D") var create_marker_action := create_point
@export_tool_button("Clear Markers", "Clear") var clear_markers_action := clear_markers


@onready var rig: CameraRig


func _ready() -> void:
	if not get_parent() is CameraRig:
		printerr("camera \"" + name + "\" doesn't have a rig as a parent")
		return

	rig = get_parent() as CameraRig


func create_point() -> void:
	rig.create_marker(transform)


func clear_markers() -> void:
	rig.clear_markers()
