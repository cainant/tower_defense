extends Node

func _ready():
	load_main_menu()

func load_main_menu():
	var main_menu = load("res://Scenes/UI/main_menu.tscn").instantiate()
	add_child(main_menu)

	var new_game_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/NewGameButton")
	var exit_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/ExitButton")

	if new_game_button:
		new_game_button.button_down.connect(_on_new_game_pressed)
	else:
		print("ERRO: NewGameButton não encontrado!")

	if exit_button:
		exit_button.button_down.connect(_on_exit_pressed)
	else:
		print("ERRO: ExitButton não encontrado!")

func _on_new_game_pressed():
	var main_menu = get_node_or_null("MainMenu")
	if main_menu:
		main_menu.queue_free()

	var game_scene = load("res://Scenes/game_scene.tscn").instantiate()
	game_scene.name = "GameScene"
	game_scene.connect("game_end", Callable(self, "on_game_end"))
	add_child(game_scene)

func _on_exit_pressed():
	get_tree().quit()

func on_game_end(win: bool):
	var game_scene = get_node_or_null("GameScene")
	if game_scene:
		game_scene.queue_free()

	var game_over_scene = load("res://Scenes/UI/game_over.tscn").instantiate()
	game_over_scene.name = "GameWin"
	game_over_scene.find_child('MainTitle', true).text = 'You win!' if win else 'You lose.'
	
	add_child(game_over_scene)
	
	var exit_main_menu_button = game_over_scene.get_node_or_null("ExitButton/")
	if exit_main_menu_button:
		exit_main_menu_button.button_down.connect(load_main_menu)

func _on_retry_game():
	var game_over_scene = get_node_or_null("GameOver")
	if game_over_scene:
		game_over_scene.queue_free()
	else:
		print("ERRO: GameOver não encontrado!")

	_on_new_game_pressed()
