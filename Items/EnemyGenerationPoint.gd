extends Marker2D

# 计时器的间隔时间
@export var interval: float = 3.0  # 默认每3秒执行一次

#生成敌人
@onready var slime = preload("res://Charactors/slime.tscn").instantiate()

# 计时器
var _timer: float = 0.0

func _process(delta: float) -> void:
	# 更新计时器
	_timer += delta
	
	# 检查计时器是否已达到间隔时间
	if _timer >= interval:
		_timer -= interval  # 重置计时器
		_execute_function()  # 调用要执行的函数

# 你要每隔几秒执行的函数
func _execute_function() -> void:
	#print("执行函数，每隔 ", interval, " 秒调用一次")
	var slime2 = slime.duplicate()
	slime2.global_position = self.global_position
	slime2.path_move = true
	self.get_parent().get_parent().get_node("Enemys").add_child(slime2)
	slime2.path = [Vector2(584,3),World.BasePosition]
