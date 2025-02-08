extends Node

func _ready() -> void:
	load_main_menu()

func load_main_menu():
	get_node('MainMenu/MarginContainer/VBoxContainer/NewGameButton').button_down.connect(_on_new_game_pressed)
	get_node('MainMenu/MarginContainer/VBoxContainer/ExitButton').button_down.connect(_on_exit_pressed)
	
func _on_new_game_pressed() -> void:
	get_node("MainMenu").queue_free()
	var game_scene = load('res://Scenes/game_scene.tscn').instantiate()
	game_scene.connect("game_end", Callable(self, "unload_game"))

	add_child(game_scene)
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func unload_game(result):
	get_node("game_scene").queue_free()
	var main_menu = load("res://Scenes/UI/main_menu.tscn")
	add_child(main_menu)
	load_main_menu()
