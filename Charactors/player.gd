extends CharacterBody2D

# 双击检测的时间阈值
const DOUBLE_TAP_TIME :float = 0.3

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ghost_trail_scene: PackedScene = preload("res://Test/GhostTrail.tscn")
@onready var health_bar :Node2D = $Healthbar
@onready var gameover :PanelContainer = get_node("Camera2D/GUI/gameover")
@onready var walk_sound :AudioStreamPlayer = $Sounds/walk_sound  # 引用走路音效节点
@onready var jump_sound :AudioStreamPlayer = $Sounds/jump_sound  # 引用跳跃音效节点
@onready var melee_attack :Marker2D = $Melee_Attack
@onready var ranged_attack :Marker2D = $Ranged_Attack


@export var SPEED :float = 150.0 # 玩家移动速度
@export var JUMP_VELOCITY :float = -300.0 # 玩家跳跃速度
@export var ACCELERATION_SPEED :float = SPEED * 6.0 # 定义常量加速度为步行速度的6倍
@export var TERMINAL_VELOCITY :int = 700 # 定义玩家下落的最大速度为700
@export var DASH_MULTIPLIER :float = 1.7 # 定义加速后的速度倍率
@export var energy : int = 100 #玩家饥饿值
@export var fly_speed :float = 300.0 #飞行速度
@export var is_flying :bool = false # 添加飞行状态变量
# 摔落伤害相关变量
@export var enable_fall_damage: bool = true # 是否开启摔落伤害
@export var fall_damage_threshold: float = 500.0 # 开始计算摔落伤害的速度阈值
@export var max_fall_damage: int = 50 # 最大摔落伤害
# 用于记录下落过程中的最大速度
@export var can_jump: bool = true  # 控制是否可以跳跃
@export var can_move: bool = true  # 控制是否可以移动,跳跃
@export var can_shoot: bool = true  # 控制是否可以射击
@export var can_action: bool = true # 控制玩家一切动作


var max_fall_speed: float = 0.0
# 获取和刚体一样自带的重力效果
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
# 定义变量_double_jump_charged，初始值为false，表示是否充能双跳
var _double_jump_charged :bool = false
var action_suffix :String = ""

# 记录按键的最后按下时间
var last_d_press_time :float = 0.0
var last_a_press_time :float = 0.0
# 是否处于加速状态
var is_dashing :bool = false
#获取玩家原来的颜色，来实现攻击玩家动画
var original_color :Color

var walk_sound_timer: float = 0.0
var walk_sound_interval: float = 0.3  # 设置走路音效播放间隔

var current_mode = AttackMode.MELEE  # 当前攻击模式，默认为近战模式
# 获取玩家节点的材质
@onready var player_material = animated_sprite_2d.material

# 定义攻击模式的枚举
enum AttackMode {
	MELEE,  # 近战
	RANGED,  # 远程
	MAGIC   # 魔法
} 

#--------初始属性---------
var init_speed :float = SPEED #初始速度
var init_jump_speed :float = JUMP_VELOCITY #初始跳跃高度
var init_acceleration :float = ACCELERATION_SPEED #初始加速度
var init_falling_speed :float = TERMINAL_VELOCITY #初始下落速度
var init_dash_times :float = DASH_MULTIPLIER #初始冲刺状态的速度倍数
var init_max_health :float#初始最大血量
var init_max_shield :float#初始最大护盾
var init_damage_reduction_percent :float#初始伤害减免百分比
var init_size :Vector2#初始玩家大小
var init_energy :float=energy #初始玩家饥饿值
#--------初始属性---------

# 新增的计时器和计数器
var move_timer :float = 0.0
var jump_count :int = 0
var shoot_count :int = 0

# 减少energy的时间间隔
var next_move_energy_time :int = randi_range(30, 60) #移动消耗饥饿值间隔
var next_jump_energy_count :int = randi_range(6, 9)  #跳跃消耗饥饿值间隔
var health_restore_timer :float = 0.0
var health_loss_timer :float = 0.0

func _ready():
	
	#获取玩家原来的颜色，来实现攻击玩家动画
	original_color = animated_sprite_2d.modulate
	
	init_max_health = health_bar.max_health
	init_max_shield = health_bar.max_shield
	init_damage_reduction_percent = health_bar.damage_reduction_percent
	init_size = self.scale 
	pass

func _physics_process(delta: float) -> void:
	#执行近战攻击逻辑
	if Input.is_action_pressed("melee_attack" + action_suffix) and current_mode == AttackMode.MELEE:
		melee_attack.start_swing()  # 开始扫动
		pass
	
	#按Q键切换攻击模式（远程，近战，魔法）         current_mode == AttackMode.MELEE
	if Input.is_action_just_pressed("switch_attack_mode" + action_suffix):
		toggle_attack_mode()
		pass
	
	if not can_action:
		return
	
	if velocity.y > max_fall_speed:
		max_fall_speed = velocity.y
	
	# 获取鼠标在世界坐标中的位置
	var mouse_position = get_global_mouse_position()

	# 如果鼠标在角色左侧，则翻转角色朝向左边；否则朝向右边
	if mouse_position.x < global_position.x:
		animated_sprite_2d.scale.x = -1  # 翻转角色朝向左边
	else:
		animated_sprite_2d.scale.x = 1  # 翻转角色朝向右边
	
	
	#print(next_move_energy_time) 发现随机数被定义后为确定值，需再次定义来能随机
	# 能量恢复和生命丢失逻辑
	if float(energy) / float(init_energy) >= 0.85:
		# 如果能量超过85%，则每秒恢复1点生命值
		health_restore_timer += delta
		health_loss_timer = 0.0  # 重置损失生命值的计时器

		if health_restore_timer >= 0.7:
			health_bar.heal(1)  # 恢复1点生命值
			health_restore_timer = 0.0  # 重置恢复计时器

	elif float(energy) / float(init_energy) < 0.01:
		# 如果能量低于1%，则每秒损失1点生命值
		health_loss_timer += delta
		health_restore_timer = 0.0  # 重置恢复生命值的计时器

		if health_loss_timer >= 0.7:
			health_bar.take_damage(1)  # 减少1点生命值
			health_loss_timer = 0.0  # 重置损失计时器

	else:
		# 如果不符合任何条件，重置所有计时器
		health_restore_timer = 0.0
		health_loss_timer = 0.0
	
	# 移动能量消耗计时器更新
	move_timer += delta
	
	# 玩家失去全部血量执行逻辑
	if health_bar.is_dead() == true:
		#print("游戏结束！")
		gameover.show()
		can_action = false
		pass
	
	# 玩家移动和双跳逻辑
	if is_on_floor():
		#print("在地板上")
		_double_jump_charged = true
		if enable_fall_damage and max_fall_speed > fall_damage_threshold:
			print(max_fall_speed)
			apply_fall_damage(max_fall_speed)
			max_fall_speed = 0.0  # 重置最大下落速度
			_double_jump_charged = true
	
	if Input.is_action_just_pressed("up" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("up" + action_suffix) and velocity.y < 0.0:
		# 提早松开跳跃键时减少上升动量
		velocity.y *= 0.5
	
	# 飞行状态下的逻辑
	if is_flying:
		SPEED = 1500.0
		# 检查 W 和 S 键
		if Input.is_action_pressed("fly"):  
			velocity.y = -fly_speed  # 向上飞
		elif Input.is_action_pressed("fall"):  
			velocity.y = fly_speed  # 向下飞
		else:
			velocity.y = 0.0  # 如果没有按键，则不移动

	else:
		# 应用重力
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)  # 应用重力


#---------------------玩家移动逻辑-------------------
	# 检测双击D和A键进行加速
	check_double_tap()

	# 获取输入方向并计算水平速度
	var direction := Input.get_axis("left" + action_suffix, "right" + action_suffix)
	# 空中移动修正 - 允许在空中调整方向
	var final_speed = SPEED
	
	if is_dashing:
		final_speed *= DASH_MULTIPLIER

	if not is_on_floor():
		velocity.x = lerp(velocity.x, direction * final_speed * 0.5, 0.1)
	else:
		velocity.x = move_toward(velocity.x, direction * final_speed, ACCELERATION_SPEED * delta)

	# 根据移动方向翻转精灵
	if not is_zero_approx(velocity.x):
		animated_sprite_2d.scale.x = sign(velocity.x)

	if can_move:
		# 移动并在碰撞时滑动
		move_and_slide()
#---------------------玩家移动逻辑-------------------

	# 检查是否需要减少移动能量
	if move_timer >= next_move_energy_time:
		reduce_energy(-1)
		move_timer = 0.0
		next_move_energy_time = randi_range(30, 60)

	# 射击逻辑
	if Input.is_action_pressed("shoot" + action_suffix) and can_shoot and current_mode == AttackMode.RANGED:
		if World.bullet_number >= 0:
			shoot_bullet()
			pass
		else :
			print("没有子弹了！")
			pass
	
	# 更新计时器
	walk_sound_timer += delta		
	# 播放走路音效
	if direction != 0 and is_on_floor():
		if walk_sound_timer >= walk_sound_interval:
			if not walk_sound.playing:
				walk_sound.play()
			walk_sound_timer = 0.0  # 重置计时器
	else:
		walk_sound.stop()

# 尝试跳跃的函数
func try_jump() -> void:
	if not can_jump:
		return  # 如果跳跃被禁用，则不执行跳跃逻辑
	
	if is_on_floor():
		# 在地面上跳跃
		# 播放跳跃音效
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		jump_sound.play()
	elif _double_jump_charged:
		_double_jump_charged = false
		# 双跳时更高的垂直速度
		velocity.y = JUMP_VELOCITY * 1.2
		jump_count += 1
		jump_sound.play()
	else:
		return
	
	# 检查是否需要减少跳跃能量
	if jump_count >= next_jump_energy_count:
		reduce_energy(-1)
		jump_count = 0
		next_jump_energy_count = randi_range(6, 9)

# 发射子弹的自定义函数
func shoot_bullet() -> void:
	# 计算鼠标在世界坐标的当前位置
	var mouse_position = get_global_mouse_position()
	# 计算发射方向
	var direction = (mouse_position - global_position).normalized()
	
	# 设置玩家朝向
	animated_sprite_2d.scale.x = sign(direction.x)  # 根据方向翻转精灵
	
	# 调用枪的射击方法
	ranged_attack.shoot()
	shoot_count += 1

func being_team():
	return "玩家"

# 检测双击A和D键来加速
func check_double_tap() -> void:
	# 获取当前时间
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 检查D键双击
	if Input.is_action_just_pressed("right" + action_suffix):
		if current_time - last_d_press_time <= DOUBLE_TAP_TIME and energy / float(init_energy) >= 0.3:
			is_dashing = true
		last_d_press_time = current_time
	elif Input.is_action_just_released("right" + action_suffix):
		is_dashing = false
	
	# 检查A键双击
	if Input.is_action_just_pressed("left" + action_suffix):
		if current_time - last_a_press_time <= DOUBLE_TAP_TIME and energy / float(init_energy) >= 0.3:
			is_dashing = true
		last_a_press_time = current_time
	elif Input.is_action_just_released("left" + action_suffix):
		is_dashing = false

#减少玩家饥饿值的逻辑,正数为加，负数为减，int类型
func reduce_energy(value: int)-> void:
	if energy >= 0 and energy <= init_energy:
		energy += value
		pass
	pass

# 生成角色残影
func generate_residual_image():
	if self.velocity.length() > 0:
		## 复制当前的 AnimatedSprite2D 节点
		var animated = animated_sprite_2d.duplicate()
		animated.material=null
		#animated.material.set_shader_parameter("gold_effect_enabled", false)
		## 设置残影的透明度
		animated.modulate = Color(0.5, 0.7, 1.0, 0.7)  # 初始透明度为 50%
		animated.global_position = self.global_position + Vector2(0,-15)
		## 将残影添加为当前节点的子节点
		self.get_parent().add_child(animated)
		
		## 将残影置于角色后面
		animated.z_index = animated_sprite_2d.z_index - 1
		animated.stop()
		var duration = 0.8
		var steps = 60  # 增加更新次数，使动画更加流畅
		var fade_speed = animated.modulate.a / (duration * steps)  # 每次更新减少的透明度

		while animated.modulate.a > 0:
			animated.modulate.a -= fade_speed  # 逐渐减少透明度
			if animated.modulate.a <= 0:
				animated.modulate.a = 0
				break
			await get_tree().create_timer(duration / steps).timeout  # 更频繁地更新
			
		animated.queue_free()  # 当透明度为 0 时，移除节点
	
#让实体变红一瞬间，用来制作实体受伤动画
func flash_red(body):
	body.animated_sprite_2d.modulate = Color(1, 0, 0)  # 设置为红色
	await get_tree().create_timer(0.1).timeout  # 等待 0.2 秒
	body.animated_sprite_2d.modulate = original_color  # 恢复原始颜色

#计算摔落伤害
func apply_fall_damage(fall_speed: float) -> void:
	# 计算超过阈值部分的下落速度占比
	var damage = int((fall_speed - fall_damage_threshold) / (TERMINAL_VELOCITY - fall_damage_threshold) * max_fall_damage)
	damage = max(1, damage)  # 确保伤害至少为1
	health_bar.take_damage(damage)
	print("玩家受到摔落伤害: %d, 下落速度: %f" % [damage, fall_speed])
	flash_red(self)

# 切换攻击模式的函数
func toggle_attack_mode():
	# 在枚举中切换模式
	current_mode = int(current_mode) + 1  # 增加模式编号
	if current_mode > AttackMode.MAGIC:  # 如果超过最后一个模式，回到第一个
		current_mode = AttackMode.MELEE

	match current_mode:
		AttackMode.MELEE:
			print("切换到近战模式")
			melee_attack.show()
			ranged_attack.hide()
		AttackMode.RANGED:
			ranged_attack.show()
			melee_attack.hide()
			print("切换到远程模式")
		AttackMode.MAGIC:
			ranged_attack.hide()
			melee_attack.hide()
			print("切换到魔法模式")

# 让角色变红（例如，受到攻击时调用）
func player_hit():
	# 设置角色变红
	player_material.set_shader_parameter("is_hit", true)
	player_material.set_shader_parameter("hit_intensity", 1.0)
	
	# 等待 2 秒后恢复
	await get_tree().create_timer(0.2).timeout
	
	# 恢复正常
	player_material.set_shader_parameter("is_hit", false)
	
	

#-------以下方法只在原来属性的基础上修改-----------SPEED *= power
#-------且带有持续时间，供其他实体调用----------------

#设置玩家速度，包括加速和减速，初始速度为150.0
func set_speed(power: float, time: float) -> void:
	SPEED = power * init_speed
	await get_tree().create_timer(time).timeout
	SPEED = init_speed

#设置玩家大小，初始玩家大小为vec（1,1）
func set_size(power: float, time: float) -> void:
	self.scale = power * init_size
	await get_tree().create_timer(time).timeout
	self.scale = init_size
	pass

#设置玩家攻击伤害，还没来得及想怎么实现！！！！！
func set_damage(power: float, time: float) -> void:
	self.scale *= power
	await get_tree().create_timer(time).timeout
	self.scale = init_size
	pass

#设置玩家最大血量，正数为加血量，负数为减少血量
func set_max_health(power: int, time: float) -> void:
	health_bar.max_health = power + init_max_health
	await get_tree().create_timer(time).timeout
	health_bar.max_health = init_max_health
	pass

#设置玩家最大护盾，正数为加护盾，负数为减少护盾
func set_max_shield(power: int, time: float) -> void:
	health_bar.max_shield = power + init_max_shield
	await get_tree().create_timer(time).timeout
	health_bar.max_shield = init_max_shield
	pass

#设置伤害减免百分比（0-100%）
func set_damage_reduction(power: float, time: float) -> void:
	health_bar.set_damage_reduction(power)
	await get_tree().create_timer(time).timeout
	health_bar.damage_reduction_percent = init_damage_reduction_percent
	pass

#设置玩家相对于初始属性跳跃高度(初始-300) 
func set_jump_height(power: float, time: float) -> void:
	JUMP_VELOCITY = power * init_jump_speed
	await get_tree().create_timer(time).timeout
	JUMP_VELOCITY = init_jump_speed
	pass

#设置玩家相对于初始属性降落速度(初始-700)（可以实现MC的缓降效果）
func set_falling_speed(power: float, time: float) -> void:
	TERMINAL_VELOCITY = power * init_falling_speed
	await get_tree().create_timer(time).timeout
	TERMINAL_VELOCITY = init_falling_speed
	pass
