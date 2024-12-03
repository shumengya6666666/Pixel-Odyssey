extends Node2D

# 获取检测和攻击范围的 Area2D 节点
@onready var detection_area = $DetectionArea2D
@onready var attack_area = $AttackArea2D

func _ready():
# 连接 Area2D 的信号
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	attack_area.connect("body_exited", Callable(self, "_on_attack_area_body_exited"))
	pass
	
	
# 当检测范围的 Area2D 检测到玩家进入时
func _on_detection_area_body_entered(body):
	if body is CharacterBody2D:
		#print(body.global_position)
		#target = body
		#_is_moving = false
		#moving_towards_player = true
		pass
	pass 

# 当检测范围的 Area2D 检测到玩家离开时
func _on_detection_area_body_exited(body):
	if body is CharacterBody2D:
		#moving_towards_player = false
		#target = null
		#_random_move()
		pass
	pass 

# 当攻击范围的 Area2D 检测到玩家进入时
func _on_attack_area_body_entered(body):
	if body is CharacterBody2D:
		#attack()
		pass
	pass 

# 当攻击范围的 Area2D 检测到玩家离开时
func _on_attack_area_body_exited(body):
	if body is CharacterBody2D:
		# 可能需要在这里执行一些逻辑，例如停止攻击
		pass
	pass 
