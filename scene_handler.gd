extends Node

func _ready() -> void:
	get_node('MainMenu/MarginContainer/VBoxContainer/NewGameButton').button_down.connect(_on_new_game_pressed)
	get_node('MainMenu/MarginContainer/VBoxContainer/ExitButton').button_down.connect(_on_exit_pressed)

func _on_new_game_pressed() -> void:
	get_node("MainMenu").queue_free()
	var game_scene = load('res://Scenes/game_scene.tscn').instantiate()
	add_child(game_scene)
	
func _on_exit_pressed() -> void:
	get_tree().quit()
