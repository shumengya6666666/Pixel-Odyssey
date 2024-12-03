extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer

# 生长阶段（总共有4个阶段）
@export var growth_stage = 1
#最小生长时间
@export var min_growth_time = 120
#最大生长时间
@export var max_growth_time = 240
# 可拾取效果参数
var pickup_effect = 0

func _ready():
	
	if growth_stage < 4:
		# 更新动画帧
		animated_sprite_2d.frame = growth_stage
	
	# 初始化计时器，每2到4分钟调用一次 _on_timer_timeout
	timer.wait_time = randi_range(120, 240)  # 2-4分钟之间
	#timer.connect("timeout", self, Callable(self, "_on_timer_timeout"))
	timer.start()

func _on_body_entered(body):
	# 根据生长阶段调整拾取效果
	match growth_stage:
		0:
			pickup_effect = 1
		1:
			pickup_effect = 2
		2:
			pickup_effect = 3
		3:
			pickup_effect = 4
	
	# 拾取效果代码
	apply_pickup_effect(body, pickup_effect)
	
	# 移除水果
	self.queue_free()

func _on_timer_timeout():
	# 增加生长阶段
	growth_stage += 1

	if growth_stage < 4:
		# 更新动画帧
		animated_sprite_2d.frame = growth_stage

		# 重新启动计时器
		timer.wait_time = randi_range(1, 10)  # 2-4分钟之间
		timer.start()
	else:
		# 如果达到最后阶段，停止计时器
		timer.stop()

func apply_pickup_effect(body, effect):
	match effect:
		1:
			# 处理 effect 为 1 时的逻辑
			print("拾取阶段效果: 1 - 增加少量分数")

		2:
			# 处理 effect 为 2 时的逻辑
			print("拾取阶段效果: 2 - 增加中量分数，并给予小的生命恢复")

		3:
			# 处理 effect 为 3 时的逻辑
			print("拾取阶段效果: 3 - 增加大量分数，并给予大的生命恢复")

		4:
			# 处理 effect 为 4 时的逻辑
			print("拾取阶段效果: 4 - 大幅增加分数，并给予极大的生命恢复和临时加速效果")

		_:
			print("未知的拾取效果")
