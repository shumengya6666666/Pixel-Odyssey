extends Label

# 记录时间变量
var start_time: float = 0.0
var is_timing: bool = false

func _ready():
	# 设置 Label 的文本颜色为淡蓝色
	modulate = Color(0.7, 0.7, 1.0)
	# 开始计时
	start_timer()

func _process(delta: float):
	# 如果正在计时，实时更新显示
	if is_timing:
		var current_time = Time.get_ticks_msec()
		var elapsed_time = current_time - start_time
		_update_label(elapsed_time)

# 开始计时
func start_timer():
	start_time = Time.get_ticks_msec()
	is_timing = true

# 停止计时并显示最终结果
func stop_timer():
	if is_timing:
		is_timing = false
		var end_time = Time.get_ticks_msec()
		var elapsed_time = end_time - start_time
		_update_label(elapsed_time)
		print("通关时间为: %s" % _format_time(elapsed_time))

# 更新 Label 显示时间
func _update_label(time_msec: int):
	text = "游玩时间："+_format_time(time_msec)

# 将时间格式化为时:分:秒.毫秒
func _format_time(time_msec: int) -> String:
	var total_seconds = time_msec / 1000.0
	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	var seconds = total_seconds - (hours * 3600 + minutes * 60)
	return "%02d:%02d:%06.3f" % [hours, minutes, seconds]
