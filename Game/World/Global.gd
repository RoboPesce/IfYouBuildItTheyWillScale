extends Node

const MAX_BLOCK_HEIGHT : int = 30
const BLOCKS_PER_SIDE : int = 5

# @param factor: proportion of the distance between source and target to travel
func lerp(source, target, factor : float):
	return source * (1 - factor) + target * factor

# can be used for doubles or vectors
# @param damping_factor: rate at which source approaches target per second
#						 i.e. remaining proportion of source after 1 second
func FrameIndependentDamping(source, target, damping_factor : float, delta : float):
	var factor : float = pow(damping_factor, delta)
	return lerp(source, target, 1 - factor)

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
