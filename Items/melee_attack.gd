extends Marker2D

# 定义旋转的参数
var rotation_speed := 14.0  # 控制旋转速度
var max_rotation_angle := PI /1.5  # 最大摆动角度（上下扫动的范围）
var current_time := 0.0  # 用于跟踪时间的变量
var is_swinging := false  # 标志是否在进行攻击
var swing_duration := 0.5  # 扫动持续的时间
var swing_progress := 0.0  # 扫动的进度，用于控制扫动动画
var attack_damage = 10
# 用于翻转角色的属性
var is_facing_left := false  # 标记角色当前是否朝左

# 保存初始的 x 坐标偏移量
var initial_position_x := 10  # 初始设置的x位置偏移

# 当前近战武器的索引
var current_weapon_index := 0

# 定义近战武器的字典
const WEAPON_TEXTURE_DICT = {
	"Diamond_Sword": preload("res://MC/diammond_sword.tres"),
	"Gold_Sword": preload("res://MC/golden_sword.tres"),
	"Iron_Sword": preload("res://MC/iron_sword.tres")
}

# 获取近战武器的键列表
var weapon_keys = WEAPON_TEXTURE_DICT.keys()

# 跟踪当前的武器名称
var current_weapon_name = weapon_keys[current_weapon_index]

# 预加载当前武器纹理
@onready var weapon_sprite = $Melee_Texture  

# 定义一个字典，关联每种武器与其特定的切换行为
var weapon_switch_functions = {
	"Diamond_Sword": attack_with_diamond_sword,
	"Gold_Sword": attack_with_gold_sword,
	"Iron_Sword": attack_with_iron_sword
}

func _ready():
	# 初始化显示的武器
	update_weapon_texture()
	position.x = initial_position_x  # 初始设置位置
	# 执行当前武器的切换逻辑
	weapon_switch_functions[current_weapon_name].call()
	pass


func _process(delta):
	# 检测是否按下切换键（例如R键）
	if Input.is_action_just_pressed("change"):  # "change_weapon" 映射到 R 键
		switch_melee_weapon()

	# 获取鼠标在世界坐标中的位置
	var mouse_position = get_global_mouse_position()

	# 翻转角色，并根据方向调整 position.x
	if mouse_position.x < global_position.x and not is_facing_left:
		is_facing_left = true
		self.scale.x = -1  # 翻转角色朝向左边
		position.x = -initial_position_x  # 调整武器的位置
	elif mouse_position.x >= global_position.x and is_facing_left:
		is_facing_left = false
		self.scale.x = 1  # 翻转角色朝向右边
		position.x = initial_position_x  # 恢复原始位置
	
	# 如果正在扫动，进行动画
	if is_swinging:
		swing_progress += delta * rotation_speed  # 更新进度

		# 根据朝向设置旋转方向
		var rotation_direction = -1 if is_facing_left else 1
		self.rotation = sin(swing_progress) * max_rotation_angle * rotation_direction

		# 检查是否扫动完成
		if swing_progress >= PI:
			is_swinging = false  # 停止扫动
			self.rotation = 0  # 重置旋转角度
	pass


func start_swing():
	# 开始一次扫动
	if not is_swinging:
		is_swinging = true  # 标记开始扫动
		swing_progress = 0.0  # 重置扫动进度
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("敌人"):
		if body is CharacterBody2D or body is RigidBody2D:
			# 如果 body 是一个具有 velocity 属性的节点
			var knockback_direction = (body.global_position - global_position).normalized()
			var knockback_strength = 200.0
			body.velocity += knockback_direction * knockback_strength
			print(body.name + " 正在被近战攻击！")
			var enemyhealth = body.get_node("Healthbar")
			enemyhealth.take_damage(attack_damage)
	pass

# 切换近战武器的函数
func switch_melee_weapon():
	# 增加当前武器索引并循环回到开头
	current_weapon_index = (current_weapon_index + 1) % weapon_keys.size()
	current_weapon_name = weapon_keys[current_weapon_index]
	update_weapon_texture()
	# 执行新武器的切换逻辑
	weapon_switch_functions[current_weapon_name].call()

func update_weapon_texture():
	# 更新武器的纹理
	weapon_sprite.texture = WEAPON_TEXTURE_DICT[current_weapon_name]

# 定义不同武器的切换逻辑
func attack_with_diamond_sword():
	print("切换到钻石剑，执行特定行为！")
	attack_damage = 20
	rotation_speed = 10
	# 在这里可以实现特定于钻石剑的行为
	pass

func attack_with_gold_sword():
	print("切换到金剑，执行特定行为！")
	attack_damage = 12
	rotation_speed = 15
	# 在这里可以实现特定于金剑的行为
	pass

func attack_with_iron_sword():
	print("切换到铁剑，执行特定行为！")
	attack_damage = 16
	rotation_speed = 10
	# 在这里可以实现特定于铁剑的行为
	pass
