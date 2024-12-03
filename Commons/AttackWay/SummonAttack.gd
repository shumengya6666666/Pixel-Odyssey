#召唤攻击类

# SummonAttack.gd
extends Attack

@export var summon_scene: PackedScene

# 执行召唤攻击
func execute_attack(target):
	emit_signal("attack_started", target)
	var summon = summon_scene.instance()
	summon.global_position = global_position
	get_tree().current_scene.add_child(summon)
	emit_signal("attack_finished", target)
