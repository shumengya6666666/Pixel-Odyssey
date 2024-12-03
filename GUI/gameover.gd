extends PanelContainer

@onready var killed_enemy_number = $VBoxContainer/ScrollContainer/VBoxContainer/Killed_Enemy_Number

func _ready():
	killed_enemy_number.text = "杀死敌人数量："+str(World.killed_enemy)
	pass

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://Main/game.tscn")
	pass 


func _on_back_home_pressed():
	get_tree().change_scene_to_file("res://GUI/gamemenu.tscn")
	pass 
