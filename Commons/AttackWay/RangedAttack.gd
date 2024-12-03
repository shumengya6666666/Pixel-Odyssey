#远程攻击类

# RangedAttack.gd
extends Attack

@export var projectile_scene: PackedScene

# 执行远程攻击
func execute_attack(target):
	emit_signal("attack_started", target)
	var projectile = projectile_scene.instance()
	projectile.global_position = self.global_position
	projectile.target = target
	get_tree().current_scene.add_child(projectile)
	emit_signal("attack_finished", target)
