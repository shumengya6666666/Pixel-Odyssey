extends TextureRect

# 定义变量
var distance = 120  # 每次移动的距离
var speed = 30  # 移动速度（像素/秒）
var directions = ['up', 'right', 'down', 'left']  # 移动方向顺序
var current_direction = 0  # 当前移动的方向索引
var target_position = Vector2()  # 目标位置
var infinite_loop = true  # 控制是否无限循环，设置为 true 开启无限循环

func _ready():
	# 初始化目标位置为节点当前的位置
	target_position = position
	move_to_next_target()  # 开始移动到第一个目标位置
	# 调用函数获取并打印四个顶点的全局坐标
	var corners = get_corners_global_positions()

func _process(delta):
	# 移动节点到目标位置
	var direction_vector = (target_position - position).normalized()
	position += direction_vector * speed * delta

	# 当节点接近目标位置时，切换到下一个目标
	if position.distance_to(target_position) < 1.0:
		position = target_position
		move_to_next_target()

# 计算下一个目标位置
func move_to_next_target():
	# 根据当前方向计算新的目标位置
	match directions[current_direction]:
		'up':
			target_position.y -= distance
		'right':
			target_position.x += distance
		'down':
			target_position.y += distance
		'left':
			target_position.x -= distance

	# 更新当前方向索引，确保循环回到 'up' 时重置方向
	current_direction = (current_direction + 1) % 4

	# 如果无限循环为 false，则停止移动（默认无限循环）
	if not infinite_loop and current_direction == 0:
		queue_free()  # 停止并删除节点

func get_corners_global_positions():
	# 获取 TextureRect 的全局位置和大小
	var global_position = self.global_position
	var size = get_texture().get_size()


	# 计算四个顶点的全局坐标
	var top_left = global_position
	var top_right = global_position + Vector2(size.x, 0)
	var bottom_left = global_position + Vector2(0, size.y)
	var bottom_right = global_position + Vector2(size.x, size.y)

	# 打印全局坐标
	print("Top Left (Global): ", top_left)
	print("Top Right (Global): ", top_right)
	print("Bottom Left (Global): ", bottom_left)
	print("Bottom Right (Global): ", bottom_right)

	# 返回全局坐标的字典
	return {
		"top_left": top_left,
		"top_right": top_right,
		"bottom_left": bottom_left,
		"bottom_right": bottom_right
	}
