extends CharacterBody2D
#-------------------初始化变量声明----------------------------#
# 获取动画精灵节点
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# 获取玩家节点
@onready var player : CharacterBody2D = get_parent().get_parent().get_parent().get_node("Player")
@onready var playerhealth : Node2D = player.get_node("Healthbar")
@onready var health_bar : Node2D = $Healthbar
@onready var explosion_particles :CPUParticles2D = preload("res://Commons/explosion_particles.tscn").instantiate()
#塔防模式专用检测，是否存在基地节点
#对于此敌人节点get_parent().get_parent().get_parent()返回的是游戏主场景Game节点 
@onready var base :Area2D = get_node("/root/Game/tilemap/Items/beacon") if has_node("/root/Game/tilemap/Items/beacon") else null
@onready var basehealth :Node2D = get_node("/root/Game/tilemap/Items/beacon/Healthbar") if has_node("/root/Game/tilemap/Items/beacon/Healthbar") else null

#----------------导出变量声明------------------------
# 定义移动速度范围
@export var min_speed :float = 30.0  # 最小移动速度
@export var max_speed :float = 70.0  # 最大移动速度
#-------------------------------------------------#
# 跳跃相关的常量
@export var JUMP_VELOCITY :float = -50.0  # 跳跃的初始速度
@export var MAX_JUMP_HEIGHT :float = 80.0  # 最大跳跃高度（以正值表示，因为计算速度时需要）
@export var MIN_JUMP_HEIGHT :float = 25.0   # 最小跳跃高度（以正值表示）
#-------------------------------------------------#
# 移动相关的变量
@export var max_move_distance :float = 100.0  # 敌人每次移动的最大距离
@export var min_move_distance :float = 50.0   # 敌人每次移动的最小距离
#-------------------------------------------------#
# 定义质量的范围
@export var min_mass :float = 1.0  # 敌人的最小质量
@export var max_mass :float = 2.0  # 敌人的最大质量
#-------------------------------------------------#
# 定义检测和攻击的范围
@export var detection_range :float = 100.0  # 检测范围
@export var attack_range :float = 20.0  # 攻击范围
#-------------------------------------------------#
@export var show_detection_range :bool = false  # 显示检测范围
@export var show_attack_range :bool = false  # 显示攻击范围
#-------------------------------------------------#
# 定义敌人下落的最大速度
@export var TERMINAL_VELOCITY :int = 700  # 终端速度（最大下落速度）
#-------------------------------------------------#
@export var path: PackedVector2Array = [] # 路径点数组
@export var path_move :bool = false #塔防模式特有的移动方式
#检测时间间隔
@export var detection_interval : float = 0.5

# -------------内部变量声明----------------------
# 敌人的初始位置
var start_position: Vector2  
# 敌人移动的目标位置
var move_target_position: Vector2  
# 上一次记录的X坐标，用于检测卡住
var last_x_position: float 
# 敌人是否卡住的标志
var _is_stuck :bool = false  
# 敌人是否正在移动的标志
var _is_moving :bool = false 
# 敌人的质量 
var mass: float  
# 敌人的移动速度
var speed: float  
# 标志位，是否在朝向玩家移动
var moving_towards_player :bool = false  
#获取玩家原来的颜色，来实现攻击玩家动画
var original_color :Color
# 定义加速度为步行速度的4倍
# 加速度，根据速度计算得出
var acceleration_speed: float  
# 获取和刚体一样自带的重力效果
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
# 当前路径点索引
var current_path_index :int = 0  
#-------------------------------------------------#
# 初始化敌人状态
func _ready():

	#获取玩家原来的颜色，来实现攻击玩家动画
	original_color = player.animated_sprite_2d.modulate
	# 随机化敌人的质量
	mass = randf_range(min_mass, max_mass)
	
	# 随机化敌人的速度
	speed = randf_range(min_speed, max_speed)
	
	# 根据速度计算加速度
	acceleration_speed = speed * 4.0
	
	# 初始化最后的X坐标
	last_x_position = position.x

	# 开始异步检测卡住并根据情况采取行动
	_check_stuck_and_act()
	
	# 随机选择一个初始的移动目标
	_random_move()

	# 每1秒检测一次与玩家的距离
	_check_player_distance()
	# 每1秒检测一次与基地的距离
	if base != null:
		print("base 存在！")
		_check_base_distance()
	else:
		print("base不存在！")

#-------------------------------------------------#
# 在每一帧中更新敌人的物理状态
func _physics_process(delta: float) -> void:
	
	if health_bar.is_dead() == true:
		self.queue_free()
		World.killed_enemy += 1
		pass
	
	# 处理重力和下落速度
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	# 如果正在向玩家移动
	if moving_towards_player:
		_move_towards_position(player.global_position)
		
	elif path_move == false:
		# 如果没有检测到玩家，按照原始逻辑移动
		if _is_moving:
			var direction = sign(move_target_position.x - position.x)
			velocity.x = move_toward(velocity.x, direction * speed, acceleration_speed * delta)

			if abs(position.x - move_target_position.x) < 1.0:
				_is_moving = false  # 停止移动
				_random_move()  # 选择新的移动目标
			pass
	else :
		move_path()
		pass

	# 根据移动方向翻转精灵方向
	if not is_zero_approx(velocity.x):
		animated_sprite_2d.scale.x = sign(velocity.x)

	# 移动并处理与其他物体的滑动和碰撞
	move_and_slide()

	# 检测碰撞并处理推动逻辑
	_detect_and_push()


#-------------------------------------------------#
# 检查与玩家的距离
func _check_player_distance() -> void:
	while true:
		await get_tree().create_timer(detection_interval).timeout

		var distance_to_player = position.distance_to(player.global_position)

		if distance_to_player <= attack_range:
			# 在攻击范围内，执行攻击
			attack(playerhealth,player)
			
		elif distance_to_player <= detection_range:
			# 在检测范围内，停止随机移动并向玩家靠近
			_is_moving = false
			moving_towards_player = true
		else:
			# 超出检测范围，恢复随机移动
			moving_towards_player = false
			if not _is_moving:
				_random_move()
				
# 检查与基地的距离
func _check_base_distance() -> void:
	while true:
		await get_tree().create_timer(detection_interval).timeout

		# 确保 base 不为 null
		if base != null:
			var distance_to_player = position.distance_to(base.global_position)

			if distance_to_player <= attack_range and basehealth != null:
				# 在攻击范围内，执行攻击
				attack(basehealth,base)
			elif distance_to_player <= detection_range:
				# 在检测范围内，停止随机移动并向玩家靠近
				_is_moving = false
				moving_towards_player = true
		else:
			print("Base节点未找到！")


#-------------------------------------------------#
# 向指定位置移动
func _move_towards_position(target_position: Vector2):
	var direction = sign(target_position.x - position.x)
	velocity.x = move_toward(velocity.x, direction * speed, acceleration_speed * get_physics_process_delta_time())


#-------------------------------------------------#
# 执行攻击
func attack(bodyhealth,body):
	# 这里是攻击逻辑
	print("攻击玩家！")
	bodyhealth.take_damage(10)
	
	if body is CharacterBody2D or body is RigidBody2D:
		# 如果 body 是一个具有 velocity 属性的节点
		var knockback_direction = (body.global_position - global_position).normalized()
		var knockback_strength = 200.0
		body.velocity += knockback_direction * knockback_strength
		body.player_hit()
	elif body is Area2D:
		# 如果 body 是 Area2D 或其他类型
		print("Area2D 类型的节点不具备 velocity 属性，无法应用击退效果。")
	else:
		print("传入的 body 类型无法识别。")
		
	#explode()

#让实体变红一瞬间，用来制作实体受伤动画
func flash_red(body):
	body.animated_sprite_2d.modulate = Color(1, 0, 0)  # 设置为红色
	await get_tree().create_timer(0.1).timeout  # 等待 0.2 秒
	body.animated_sprite_2d.modulate = original_color  # 恢复原始颜色
#-------------------------------------------------#
# 检查敌人是否卡住，并随机决定跳跃或改变方向的异步过程
func _check_stuck_and_act() -> void:
	while true:
		await get_tree().create_timer(0.3).timeout
		
		if is_on_floor() and is_zero_approx(velocity.x) and abs(position.x - last_x_position) < 1.0:
			_is_stuck = true
			
			if randf() < 0.5:
				_try_jump()
			else:
				_reverse_direction()
		else:
			_is_stuck = false

		last_x_position = position.x

#-------------------------------------------------#
# 尝试跳跃的函数
func _try_jump() -> void:
	if is_on_floor():
		var jump_height = lerp(MIN_JUMP_HEIGHT, MAX_JUMP_HEIGHT, randf())
		var jump_velocity = -sqrt(2 * gravity * jump_height)
		velocity.y = jump_velocity


#-------------------------------------------------#
# 改变移动方向的函数
func _reverse_direction() -> void:
	if _is_moving:
		move_target_position.x = position.x - (move_target_position.x - position.x)


#-------------------------------------------------#
# 随机选择一个新的移动目标
func _random_move() -> void:
	if not _is_moving:
		var move_distance = randf_range(min_move_distance, max_move_distance)
		var move_direction = 1 if randf() > 0.5 else -1
		move_target_position = position + Vector2(move_direction * move_distance, 0)
		_is_moving = true


#-------------------------------------------------#
# 处理推动逻辑
func _detect_and_push() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is CharacterBody2D and collider != self:
			var other_enemy = collider as CharacterBody2D

			if other_enemy.mass < self.mass:
				var push_direction = (other_enemy.position - self.position).normalized()
				other_enemy.velocity += push_direction * (self.mass - other_enemy.mass) * speed
				
#func _detect_and_push() -> void:
	#pass
	
#爆炸动画效果
func explode():
	if not explosion_particles.is_inside_tree():
		self.add_child(explosion_particles)
		pass
	explosion_particles.emitting = true
	pass

#画图
func _draw():
	if show_detection_range:
		draw_circle(Vector2.ZERO, detection_range, Color(0, 1, 0, 0.5))  # 绿色半透明圈
	if show_attack_range:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 0, 0, 0.5))  # 红色半透明圈

func move_path():
	if current_path_index < path.size():
		var target_position = path[current_path_index]  # 获取当前目标位置
		_move_towards_position(target_position)  # 移动到目标位置

		# 检查是否到达目标位置
		if position.distance_to(target_position) < 10.0:  # 这里的 10.0 是容差值，可以调整
			current_path_index += 1  # 移动到下一个路径点
			
			# 如果已经到达最后一个路径点，则执行结束逻辑
			if current_path_index >= path.size():
				print("定向移动已结束！")
				path_move = false
	else:
		print("定向移动已结束！")  # 如果路径已经结束，调用结束逻辑
		path_move = false
		
func _on_path_end():
	pass
