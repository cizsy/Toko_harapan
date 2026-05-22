extends Area2D

var active = false

onready var interact_icon = get_node_or_null("Interact")


func _ready():
	if not is_connected("body_entered", self, "_on_body_entered"):
		connect("body_entered", self, "_on_body_entered")

	if not is_connected("body_exited", self, "_on_body_exited"):
		connect("body_exited", self, "_on_body_exited")

	if interact_icon:
		interact_icon.visible = false


func _on_body_entered(body):
	if body.is_in_group("Player"):
		active = true


func _on_body_exited(body):
	if body.is_in_group("Player"):
		active = false


func _process(_delta):
	if interact_icon:
		interact_icon.visible = active

	if active and Input.is_action_just_pressed("interact"):
		get_tree().change_scene("res://scene/rumah.tscn")
