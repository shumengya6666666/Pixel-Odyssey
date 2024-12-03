#近战攻击类

# MeleeAttack.gd
extends Attack

@export var range: float = 50.0

# 执行近战攻击
func execute_attack(target):
	emit_signal("attack_started", target)
	if self.global_position.distance_to(target.global_position) <= range:
		target.take_damage(damage)
	emit_signal("attack_finished", target)
