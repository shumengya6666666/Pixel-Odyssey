extends Label

# 定义更新FPS显示的时间间隔为1秒
var update_time = 1.0
# 定义经过的时间
var time_passed = 0.0


# 在_process函数中进行每帧调用
func _process(delta: float) -> void:
	# 增加经过的时间
	time_passed += delta
	# 如果经过的时间超过了更新间隔时间
	if time_passed >= update_time:
		# 获取当前的FPS
		var fps = Engine.get_frames_per_second()
		# 更新标签的文本为当前的FPS
		self.text = "FPS: " + str(fps)
		# 重置经过的时间
		time_passed = 0.0
