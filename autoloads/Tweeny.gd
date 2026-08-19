extends Node


func subtween_blink(
	object: Object,
	property: NodePath,
	start_val: Variant,
	final_val: Variant,
	duration: float,
	iterations: int = 10
) -> Tween:
	var subtween := create_tween()

	object.set_indexed(property, start_val)
	for i in range(iterations):
		var wait_time := duration * pow(0.5, i + 1)
		subtween.tween_interval(wait_time / 2)
		subtween.tween_property(object, property, start_val, 0.0)
		subtween.tween_interval(wait_time / 2)
		subtween.tween_property(object, property, final_val, 0.0)
	subtween.parallel().tween_property(object, property, final_val, 0.0).set_delay(duration)

	return subtween
