## Character.gd
#extends CharacterBody2D
#@export var attack: NodePath
#@onready var attack_instance: Attack = get_node(attack)
## 执行攻击的方法
#func attack_target(target):
	#if attack_instance:
		#attack_instance.execute_attack(target)

#示例：使用攻击类
#假设你的场景中有一个敌人和一个角色，角色将使用远程攻击。
## Main.gd
#extends Node2D
#@onready var player = $Player
#@onready var enemy = $Enemy
#func _ready():
	#player.attack_target(enemy)
	
extends Node
class_name   Attack

# 定义攻击类型
enum AttackType { RANGED, MELEE, EXPLOSIVE, RAY, SUMMON }

# 导出变量，用于设置攻击类型和基本属性
@export var attack_type: AttackType
@export var damage: int = 10
@export var cooldown: float = 1.0

# 信号，用于发射攻击事件
signal attack_started(target)
signal attack_finished(target)

# 准备函数
func _ready():
	pass

# 执行攻击的方法（待子类实现）
func execute_attack(target):
	pass

