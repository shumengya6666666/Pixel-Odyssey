class_name Bullet extends RigidBody2D

@onready var timer := $Timer as Timer  # 确保有个Timer节点来控制延迟
@onready var flicker = preload("res://Commons/Flicker.gd")  # 引用 Flicker 脚本

@export var bullet_speed = 600.0 # 子弹速度
@export var damage = 50 #子弹伤害

const FLASH_DURATION = 0.5  # 闪烁持续时间
const FLASH_COUNT = 5  # 闪烁次数

var is_flashing = false

# 在销毁前播放闪烁效果
func destroy() -> void:
	
	# 调用闪烁效果并传入当前节点和场景树
	await flicker.flicker(self, get_tree())  # 传入当前节点和场景树引用
	queue_free()  # 在闪烁结束后销毁



#达到消失时间后执行的操作
func _on_timer_timeout() -> void:
	# 定时器超时后的逻辑，如需要
	destroy()
	pass



func _on_area_2d_body_entered(body):
	if body.is_in_group("敌人"):
		print(body)
		var enemyhealth = body.get_node("Healthbar")
		enemyhealth.take_damage(50)
		self.queue_free()
		pass

