射线类持续攻击类

# RayAttack.gd
extends Attack

@export var duration: float = 2.0
var ray_active: bool = false

# 执行射线类持续攻击
func execute_attack(target):
	emit_signal("attack_started", target)
	ray_active = true
	var time_passed = 0.0
	while time_passed < duration and ray_active:
		if is_instance_valid(target):
			target.take_damage(damage * get_process_delta_time())
			time_passed += get_process_delta_time()
			yield(get_tree().create_timer(0.1), "timeout")
		else:
			break
	ray_active = false
	emit_signal("attack_finished", target)

