extends Node2D
#RichTextLabel
@onready var UI = $VBoxContainer
@onready var fps = $VBoxContainer/Fps
@onready var time = $VBoxContainer/Time
@onready var player_pos = $VBoxContainer/Player_Pos
@onready var enemy_number = $VBoxContainer/Enemy_Number
@onready var bullet_number = $VBoxContainer/Bullet_Number
@onready var killed_enemy_number = $VBoxContainer/killed_Enemy_Number
@onready var energy = $VBoxContainer/Energy
#@onready var player_shield = $VBoxContainer/Player_Shield
#@onready var player_health = $VBoxContainer/Player_Health


func _process(delta):
	if World.All_UI_show:
		UI.show()
	else :
		UI.hide()
	if World.FPS_show:
		fps.show()
	else :
		fps.hide()
	if World.PlayTime_show:
		time.show()
	else :
		time.hide()
	if World.PlayerPosition_show:
		player_pos.show()
	else :
		player_pos.hide()
	if World.EnemyNumber_show:
		enemy_number.show()
	else :
		enemy_number.hide()
	if World.BulletNumber_show:
		bullet_number.show()
	else :
		bullet_number.hide()
	if World.KilledEnergy_show:
		killed_enemy_number.show()
	else :
		killed_enemy_number.hide()
	if World.Energy_show:
		energy.show()
	else :
		energy.hide()
		
	player_pos.text = "玩家位置:"+str(self.get_parent().get_parent().global_position)
	enemy_number.text = "敌人数量:"+str(self.get_parent().get_parent().get_parent().get_node("tilemap").get_node("Enemys").get_child_count())
	killed_enemy_number.text = "杀死敌人数:"+str(World.killed_enemy)
	energy.text = "饥饿值:"+str(self.get_parent().get_parent().energy)
	bullet_number.text = "剩余子弹:"+str(World.bullet_number)
	#player_shield = get_parent().get_parent().get_parent().
	#player_health
	
	if World.bullet_number <= 0:
		bullet_number.text = "剩余子弹:0"
		pass


func _on_button_pressed():
	call_deferred("_change_scene")
	pass 
	
func _change_scene():
	get_tree().change_scene_to_file("res://GUI/gamemenu.tscn")
