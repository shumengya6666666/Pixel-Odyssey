extends Node2D

# 玩家属性
@export var max_health: int = 100
@export var current_health: float = 100.0  # 将 current_health 改为 float
@export var max_shield: int = 100
@export var current_shield: float = 100.0  # 将 current_shield 改为 float
@export var damage_reduction_percent: float = 0.0

@onready var health_bar: ProgressBar = $healthbar
@onready var shield_bar: ProgressBar = $shieldbar

var target_health: float
var target_shield: float
@export var transition_speed: float = 10.0  # 控制过渡速度

func _ready():
	# 初始化目标值
	target_health = float(current_health)
	target_shield = float(current_shield)
	update_bars()
	update_health_color()
	update_shield_color()

func _process(delta: float):
	#print(current_health)
	# 检查并处理血量动画
	if abs(current_health - target_health) > 0.01:
		current_health = lerp(current_health, target_health, transition_speed * delta)
		update_bars()
		update_health_color()

	# 检查并处理护盾动画
	if abs(current_shield - target_shield) > 0.01:
		current_shield = lerp(current_shield, target_shield, transition_speed * delta)
		update_bars()
		update_shield_color()
	

func update_bars():
	health_bar.value = current_health
	health_bar.max_value = max_health
	shield_bar.value = current_shield
	shield_bar.max_value = max_shield

func update_health_color():
	var health_percentage = current_health / max_health
	if health_percentage >= 0.75:
		health_bar.modulate = Color(0, 1, 0)  # 绿色
	elif health_percentage >= 0.50:
		health_bar.modulate = Color(1, 1, 0)  # 黄色
	elif health_percentage >= 0.25:
		health_bar.modulate = Color(1, 0.5, 0)  # 橙色
	else:
		health_bar.modulate = Color(1, 0, 0)  # 红色

func update_shield_color():
	var shield_percentage = current_shield / max_shield
	var color = Color(0, 0, 0.5).lerp(Color(0.5, 0.5, 1), shield_percentage)
	shield_bar.modulate = color

func take_damage(amount: int):
	var effective_damage = amount * (1 - damage_reduction_percent / 100.0)
	
	if current_shield > 0:
		if current_shield >= effective_damage:
			target_shield -= effective_damage
			effective_damage = 0
		else:
			effective_damage -= current_shield
			target_shield = 0
	
	target_health -= effective_damage
	if target_health < 0:
		target_health = 0

func heal(amount: int):
	target_health += amount
	if target_health > max_health:
		target_health = max_health

func add_shield(amount: int):
	target_shield += amount
	if target_shield > max_shield:
		target_shield = max_shield

func set_shield(amount: int):
	target_shield = amount
	if target_shield > max_shield:
		target_shield = max_shield

func set_damage_reduction(percent: float):
	damage_reduction_percent = percent

func is_dead() -> bool:
	if current_health <= 2:
		print("实体已死亡！")
		return true
	return false
