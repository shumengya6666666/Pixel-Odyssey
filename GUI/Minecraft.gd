extends Label

# 控制缩放的参数
var scale_speed: float = 10.0  # 控制缩放速度的因子
var max_scale: float = 0.8  # 最大放大倍数
var min_scale: float = 0.5  # 最小缩小倍数
var scale_time: float = 0.0  # 用于控制时间的变量

func _process(delta: float) -> void:
	# 增加时间
	scale_time += delta * scale_speed
	
	# 计算新的缩放值
	var scale_value = lerp(min_scale, max_scale, (sin(scale_time) + 1) / 2)
	
	# 应用缩放
	self.scale = Vector2(scale_value, scale_value)
