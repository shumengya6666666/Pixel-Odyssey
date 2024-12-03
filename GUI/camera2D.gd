extends Camera2D

var move_speed = 200 # 定义移动速度，可以根据需要调整
var bounds_x = Vector2(-180, 741) # x 轴的移动范围
var bounds_y = Vector2(-180, 1223) # y 轴的移动范围

# 定义相机的移动方向
enum MoveDirection { RIGHT, UP, LEFT, DOWN }
var current_direction = MoveDirection.RIGHT # 初始方向为向右

#窗口抖动功能实现相关
var rng = RandomNumberGenerator.new()
var duration = 0
var force

func _ready():
	# 初始化位置为左下角
	position = Vector2(bounds_x.x, bounds_y.y)

func _process(delta):
	
	move_in_direction(delta)
	
	#if duration > 0 :
		#var forceX = rng.randf_range(-1,1) * force
		#var forveY =rng.randf_range(-1,1) * force
		#
		#offset = Vector2(forceX,forceY)
		#
		#duration -= delta
		#pass
	
#func shake_camera(shakeForce, shakeDuration):
	#duration = shakeDuration
	#force = shakeForce
	#
	## 根据当前的方向进行移动
	#move_in_direction(delta)

# 根据当前方向移动相机
func move_in_direction(delta):
	match current_direction:
		MoveDirection.RIGHT:
			position.x += move_speed * delta
			if position.x >= bounds_x.y: # 到达右边界
				position.x = bounds_x.y
				current_direction = MoveDirection.UP # 改变方向为向上
				
		MoveDirection.UP:
			position.y -= move_speed * delta
			if position.y <= bounds_y.x: # 到达上边界
				position.y = bounds_y.x
				current_direction = MoveDirection.LEFT # 改变方向为向左
				
		MoveDirection.LEFT:
			position.x -= move_speed * delta
			if position.x <= bounds_x.x: # 到达左边界
				position.x = bounds_x.x
				current_direction = MoveDirection.DOWN # 改变方向为向下
				
		MoveDirection.DOWN:
			position.y += move_speed * delta
			if position.y >= bounds_y.y: # 到达下边界
				position.y = bounds_y.y
				current_direction = MoveDirection.RIGHT # 改变方向为向右
