extends Control

signal return_to_menu

func _ready():
	# Garante que o botão está conectado corretamente
	var menu_button = $VBoxContainer/Button
	if menu_button:
		menu_button.pressed.connect(_on_return_to_menu_pressed)
	else:
		print("ERRO: Botão não encontrado em game_win.gd")

func _on_return_to_menu_pressed():
	emit_signal("return_to_menu")  # Emite o sinal para o SceneHandler lidar com a transição
	queue_free()  # Remove a tela de vitória
