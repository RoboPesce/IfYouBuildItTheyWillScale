extends Node

const MAX_BLOCK_HEIGHT : int = 30
const BLOCKS_PER_SIDE : int = 5

# can be used for doubles or vectors
func FrameIndependentLerp(a, b, damping_factor : float, delta : float):
	var factor = exp(log(damping_factor) * delta)
	return a * factor + b * (1 - factor)

# float implementation
func FrameIndependentClampedLerp(a : float, b : float, damping_factor : float, delta : float, max_step : float):
	if (abs(b - a) >= max_step): return a + max_step * sign(b - a)
	return FrameIndependentLerp(a, b, damping_factor, delta)
	
# vec implementation
#func FrameIndependentClampedLerpVector(a: Vector3, b: Vector3, damping_factor: float, delta: float, max_step: float):
	#if (a.is_equal_approx(b)): return b
	#var diff : Vector3 = b - a
	#var len : float = diff.length()
	#if (len >= max_step):
		#return a + max_step * diff / len
	#return FrameIndependentLerp(a, b, damping_factor, delta)
