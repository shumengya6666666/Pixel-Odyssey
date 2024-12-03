extends Area2D

@onready var panel = $Panel
@onready var label = $Panel/Label
@export var text = ""

func _ready():
	label.text = text

func _on_body_entered(body):
	panel.show()
	pass 

func _on_body_exited(body):
	panel.hide()
	pass 
