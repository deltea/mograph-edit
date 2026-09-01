@tool
class_name BeatPattern extends Node


@export var pattern: Array[bool] = []
@export_range(1, 16) var bars: int = 4:
	set(value):
		bars = value
		pattern.resize(bars * 4)
		notify_property_list_changed()


