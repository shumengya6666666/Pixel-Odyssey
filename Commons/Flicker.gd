extends Resource  # 使用 Resource 让其不绑定到任何节点

const FLASH_DURATION = 0.5  # 闪烁持续时间
const FLASH_COUNT = 5  # 闪烁次数

# 静态方法，接受一个 Node2D 对象和一个 SceneTree
static func flicker(target: Node2D, tree: SceneTree) -> void:
	var original_color = target.modulate  # 保存原始颜色

	for i in range(FLASH_COUNT):
		await tree.create_timer(FLASH_DURATION / FLASH_COUNT).timeout
		# 每次闪烁的透明度变化
		var modulate_value = 1.0 - (i % 2) * 0.5  # 奇数帧变为半透明，偶数帧变为不透明
		if target != null and is_instance_valid(target):
			target.modulate = Color(modulate_value, modulate_value, modulate_value, original_color.a)

	# 确保目标对象仍然存在
	if target != null and is_instance_valid(target):
		# 最后将目标设置为完全透明
		target.modulate.a = 0

		# 等待最后一秒后可选移除（或者在调用此方法后手动移除）
		await tree.create_timer(FLASH_DURATION / FLASH_COUNT).timeout
