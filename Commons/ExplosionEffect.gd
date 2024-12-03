extends CPUParticles2D
class_name ExplosionEffect

func _ready():
	# 设置粒子发射属性
	self.emitting = true
	self.amount = 80
	self.one_shot = true
	self.explosiveness_ratio = 1.0
	self.lifetime_randomness = 0.41
	self.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT  # 选择点发射模式
	self.spread = 180.0
	self.gravity = Vector2(0, 0)
	self.initial_velocity = 50.0
	self.angular_velocity = 0.0
	self.scale_amount_max = 4.0

	# 创建一个曲线资源用于粒子缩放
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.03125, 1))  # 使用Vector2来指定点的位置和值
	scale_curve.add_point(Vector2(1, 0.232877))

	# 应用缩放曲线到粒子节点
	self.scale_amount_curve = scale_curve

	# 开始发射粒子
	self.emitting = true
