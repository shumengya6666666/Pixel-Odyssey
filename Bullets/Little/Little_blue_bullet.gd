extends RigidBody2D

@onready var timer := $Timer as Timer  # 确保有个Timer节点来控制延迟

@export var damage = 50 #子弹伤害
@export var bullet_speed = 600.0 # 子弹速度

# 在销毁前播放闪烁效果
func destroy() -> void:
	queue_free()  



#达到消失时间后执行的操作
func _on_timer_timeout() -> void:
	# 定时器超时后的逻辑，如需要
	destroy()
	pass



func _on_area_2d_body_entered(body):
	if body.is_in_group("敌人"):
		print(body)
		var enemyhealth = body.get_node("Healthbar")
		enemyhealth.take_damage(damage)
		self.queue_free()
	elif body is TileMap:
		self.queue_free()
	pass
