extends Panel

func change_level(level: int):
	get_tree().change_scene_to_file("res://Main/game.tscn")
	World.level = level

# 为每个关卡创建对应的函数
func level1():
	change_level(1)
func level2():
	change_level(2)
func level3():
	change_level(3)
func level4():
	change_level(4)
func level5():
	change_level(5)
func level6():
	change_level(6)
func level7():
	change_level(7)
func level8():
	change_level(8)
func level9():
	change_level(9)
func level10():
	change_level(10)

