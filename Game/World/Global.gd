extends Node

const MAX_BLOCK_HEIGHT : int = 30
const BLOCKS_PER_SIDE : int = 5

var b_drag_mouse : bool
var delta_mouse : Vector2 = Vector2.ZERO
var last_mouse_pos : Vector2

func _process(delta : float) -> void:
	if (b_drag_mouse):
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		delta_mouse = mouse_pos - last_mouse_pos
		last_mouse_pos = mouse_pos

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("MouseDrag")): 
		b_drag_mouse = true
		last_mouse_pos = get_viewport().get_mouse_position()
	elif (event.is_action_released("MouseDrag")): b_drag_mouse = false

func lerp(source, target, factor : float):
	return source * factor + target * (1 - factor)

# can be used for doubles or vectors
func FrameIndependentDamping(source, target, damping_factor : float, delta : float):
	var factor : float = pow(damping_factor, delta)
	return lerp(source, target, factor)

# float implementation
func FrameIndependentClampedDamping(a : float, b : float, damping_factor : float, delta : float, max_step : float):
	if (abs(b - a) >= max_step): return a + max_step * sign(b - a)
	return FrameIndependentDamping(a, b, damping_factor, delta)
	
# vec implementation
#func FrameIndependentClampedLerpVector(a: Vector3, b: Vector3, damping_factor: float, delta: float, max_step: float):
	#if (a.is_equal_approx(b)): return b
	#var diff : Vector3 = b - a
	#var len : float = diff.length()
	#if (len >= max_step):
		#return a + max_step * diff / len
	#return FrameIndependentLerp(a, b, damping_factor, delta)
