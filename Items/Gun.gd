class_name Gun extends Marker2D

@onready var sprite_2d = $Gun_Texture
@onready var shoot_sound = $Shoot_Sound

# 子弹速度
const BULLET_VELOCITY = 600.0
# 发射间隔（秒）
const SHOOT_INTERVAL = 0.1
var current_shoot_interval: float = SHOOT_INTERVAL  # 默认值
# 跟踪当前枪的索引
var current_gun_index: int = 0

# 当前的子弹类型和射击模式
var current_bullet_type: String = "Little_red"  # 默认值
var shoot_mode = 1  # 默认值

# 子弹资源字典
const BULLET_DICT = {
	# 小子弹
	"Little_blue": preload("res://Bullets/Little/Little_blue_bullet.tscn"),
	"Little_green": preload("res://Bullets/Little/Little_green_bullet.tscn"),
	"Little_pink": preload("res://Bullets/Little/Little_pink_bullet.tscn"),
	"Little_purple": preload("res://Bullets/Little/Little_purple_bullet.tscn"),
	"Little_red": preload("res://Bullets/Little/Little_red_bullet.tscn"),
	"Little_yellow": preload("res://Bullets/Little/Little_yellow_bullet.tscn"),
	# 长子弹，碰撞体积比较大
	"Long_blue": preload("res://Bullets/Long/Long_blue_bullet.tscn"),
	"Long_purple": preload("res://Bullets/Long/Long_purple_bullet.tscn"),
	"Long_green": preload("res://Bullets/Long/Long_green_bullet.tscn"),
	"Long_orange": preload("res://Bullets/Long/Long_orange_bullet.tscn"),
	"Long_pink": preload("res://Bullets/Long/Long_pink_bullet.tscn"),
	"Long_red": preload("res://Bullets/Long/Long_red_bullet.tscn"),
	"Long_white_blue": preload("res://Bullets/Long/Long_white_blue_bullet.tscn"),
	"Long_white": preload("res://Bullets/Long/Long_white_bullet.tscn"),
	"Long_yellow": preload("res://Bullets/Long/Long_yellow_bullet.tscn")
}

# 枪械资源字典
const GUN_TEXTURE_DICT = {
	"US_Musket": preload("res://Guns/US_Musket.tres"),
	"US_Pistol": preload("res://Guns/US_Pistol.tres"),
	"US_AK47": preload("res://Guns/US_AK47.tres"),	
	"Tears_of_death":preload("res://Guns/Tears_of_death.tres")
}

# 枪配置字典，包含每种枪对应的子弹类型、射击模式和射速
const GUN_CONFIG_DICT = {
	"US_Musket": {"bullet_type": "Long_blue", "shoot_mode": 1, "shoot_interval": 0.5},
	"US_Pistol": {"bullet_type": "Little_red", "shoot_mode": 1, "shoot_interval": 0.2},
	"US_AK47": {"bullet_type": "Long_red", "shoot_mode": 1, "shoot_interval": 0.1},
	"Tears_of_death": {"bullet_type": "Long_white_blue", "shoot_mode": 7, "shoot_interval": 0.05}
}

# 跟踪时间的变量
var time_since_last_shot = 0.0

func _ready():
	# 初始化默认的子弹类型和射击模式
	var default_gun_name = GUN_TEXTURE_DICT.keys()[current_gun_index]
	var config = GUN_CONFIG_DICT[default_gun_name]
	current_bullet_type = config["bullet_type"]
	shoot_mode = config["shoot_mode"]

func _process(delta: float) -> void:
	# 检测是否按下R键
	if Input.is_action_just_pressed("change"):  # 需要确保"reload"动作映射到R键
		switch_gun_texture()
	
	# 更新时间跟踪变量
	time_since_last_shot += delta
	
	# 获取鼠标在世界坐标中的位置
	var mouse_position = get_global_mouse_position()
	
	# 计算发射方向
	var direction = (mouse_position - global_position).normalized()
	
	# 计算旋转角度
	var angle = direction.angle()
	
	# 如果旋转角度超过 90 度或小于 -90 度，水平翻转精灵
	if abs(angle) > PI / 2:
		sprite_2d.scale.x = -1  # 水平翻转图片
		# 修正旋转角度，使其在正确的方向上
		angle += PI
	else:
		sprite_2d.scale.x = 1  # 不翻转图片
	
	# 应用旋转角度到 sprite_2d
	sprite_2d.rotation = angle

# 选择发射模式的函数
func shoot() -> bool:
	if shoot_mode > 1:
		return spread_shoot(shoot_mode, current_bullet_type)
	else:
		return single_shoot(current_bullet_type)

# 单发射击函数
func single_shoot(bullet_type: String) -> bool:
	if time_since_last_shot < current_shoot_interval:
		return false

	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	# 从字典中根据传入的子弹类型实例化子弹
	var bullet_scene = BULLET_DICT.get(bullet_type)
	if bullet_scene == null:
		print("未知的子弹类型: ", bullet_type)
		return false
	
	var bullet = bullet_scene.instantiate() # 实例化子弹
	bullet.global_position = global_position
	bullet.rotation = direction.angle()
	bullet.position = self.global_position + Vector2(0, -4)
	bullet.linear_velocity = direction * bullet.bullet_speed
	bullet.set_as_top_level(true)
	get_tree().root.add_child(bullet)
	if shoot_sound.playing:
		shoot_sound.stop()  # 停止当前的播放
	shoot_sound.play()
	# 减少剩余子弹数量
	World.bullet_number -= 1
	
	# 重置计时器
	time_since_last_shot = 0.0

	return true

# 散弹射击函数
func spread_shoot(shoot_mode: int, bullet_type: String) -> bool:
	if time_since_last_shot < current_shoot_interval:
		return false

	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	# 设置子弹发射角度的偏移量，用于散射
	var spread_angle = 0.2  # 可以调整散射的角度范围

	# 从字典中根据传入的子弹类型实例化子弹
	var bullet_scene = BULLET_DICT.get(bullet_type)
	if bullet_scene == null:
		print("Invalid bullet type: ", bullet_type)
		return false
	
	for i in range(shoot_mode):
		var angle_offset = (i - (shoot_mode - 1) / 2.0) * spread_angle
		var bullet_direction = direction.rotated(angle_offset)

		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = bullet_direction.angle()
		bullet.position = self.global_position + Vector2(0, -4)
		bullet.linear_velocity = bullet_direction * bullet.bullet_speed
		bullet.set_as_top_level(true)
		get_tree().root.add_child(bullet)

	# 减少子弹数量，消耗根据发射数量倍增
	World.bullet_number -= shoot_mode

	# 重置计时器
	time_since_last_shot = 0.0

	return true


# 切换枪支纹理并更新配置
func switch_gun_texture() -> void:
	# 获取所有枪的键列表
	var gun_keys = GUN_TEXTURE_DICT.keys()

	# 增加当前枪的索引并循环回到开头
	current_gun_index = (current_gun_index + 1) % gun_keys.size()

	# 根据当前索引切换枪的纹理
	var current_gun_name = gun_keys[current_gun_index]
	var current_gun_texture = GUN_TEXTURE_DICT[current_gun_name]
	sprite_2d.texture = current_gun_texture

	# 更新子弹类型、射击模式和射速
	var config = GUN_CONFIG_DICT[current_gun_name]
	current_bullet_type = config["bullet_type"]
	shoot_mode = config["shoot_mode"]
	current_shoot_interval = config["shoot_interval"]
