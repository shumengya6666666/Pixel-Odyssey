#自爆攻击类

# ExplosiveAttack.gd
extends Attack

@export var explosion_radius: float = 100.0

# 执行自爆攻击
func execute_attack(target):
	emit_signal("attack_started", target)
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is CharacterBody2D and global_position.distance_to(body.global_position) <= explosion_radius:
			body.take_damage(damage)
	queue_free()  # 自爆后销毁自己
	emit_signal("attack_finished", target)
