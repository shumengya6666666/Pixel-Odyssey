extends Area2D

@onready var player = self.get_parent().get_parent().get_parent().get_node("Player")

func _ready():
	player.global_position = self.global_position
	
	pass
