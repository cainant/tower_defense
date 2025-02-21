extends Node2D

signal game_end(result)

var map_node
@onready var ui = get_tree().get_root().find_child("SceneHandler", true, false).find_child("GameScene", true, false).find_child("UI", true, false)
@onready var hud = ui.get_node("HUD") if ui else null
@onready var status_bar = hud.get_node("Status_bar") if hud else null
@onready var hbox_container = status_bar.get_node("Hbox_container") if status_bar else null
@onready var money_label = hbox_container.get_node("Money") if hbox_container else null

var player_hp = 100
var player_money = 100

func _ready():
	map_node = get_node('Map1')
	current_wave = 0  # Inicializa a wave com o valor 0
	
	for i in get_tree().get_nodes_in_group('build_buttons'):
		i.button_down.connect(initiate_build_mode.bind(i.get_name()))


func _process(delta: float) -> void:
	if build_mode:
		update_tower_preview()
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept") and build_mode:
		verify_and_build()
		cancel_build_mode()
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	

##
## Building tower functions
##
var build_mode = false
var build_valid = false
var build_location
var build_type
var build_tile

func initiate_build_mode(tower_type: String):
	if build_mode:
		cancel_build_mode()
	build_mode = true
	build_type = "%s_tier_1" % [tower_type.to_lower()]
	get_node('UI').set_tower_preview(build_type, get_global_mouse_position())
	
func update_tower_preview():
	var mouse_pos = get_global_mouse_position()
	var current_tile = map_node.get_node('TowerExclusion').local_to_map(mouse_pos)
	var tile_pos = map_node.get_node('TowerExclusion').map_to_local(current_tile)
	
	if map_node.get_node('TowerExclusion').get_cell_source_id(current_tile) == -1:
		build_valid = true
		build_location = tile_pos
		build_tile = current_tile
		get_node('UI').update_tower_preview(tile_pos, build_valid)
	else:
		build_valid = false
		get_node('UI').update_tower_preview(tile_pos, build_valid)
	
func verify_and_build():
	if build_valid:
		var tower_cost = GameData.tower_info[build_type]['cost']
		
		if player_money >= tower_cost:
			player_money -= tower_cost  
			update_money_display()  
			
			var new_tower = load('res://Scenes/Turrets/' + build_type + '.tscn').instantiate()
			new_tower.position = build_location
			new_tower.built = true
			new_tower.tower_type = build_type
			map_node.get_node('Towers').add_child(new_tower, true)
			new_tower.add_to_group("towers")
			map_node.get_node('TowerExclusion').set_cell(build_tile, 0, Vector2i(0, 1))
		else:
			print("Dinheiro insuficiente!")  

func update_money_display():
	if money_label:
		money_label.text = str(player_money)
	else:
		print("Erro: Nó Money não encontrado!")  




	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node('UI/TowerPreview').free()


##
## Wave functions
##
var current_wave = 0
var active_enemies = 0
var total_enemies_in_wave = 0  # Total de inimigos na wave atual
var wave_active = false
var wave_ready = false
var waves = {
	0: {  # Wave 0
		"enemies": {
			"blue_tank": 15,
			"airplane": 2
		},
		"spawn_interval": 1.0
	},
	1: {  # Wave 1
		"enemies": {
			"blue_tank": 20,
			"airplane": 5
		},
		"spawn_interval": 0.8
	},
	2: {  # Wave 2
		"enemies": {
			"blue_tank": 25,
			"airplane": 15
		},
		"spawn_interval": 0.6
	}
}

func start_new_wave():
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout
	spawn_enemies(wave_data)

func start_next_wave():
	if game_over_triggered:
		return  # Evita iniciar nova wave após game over
	
	print("Iniciando nova wave...")

	if active_enemies > 0:
		print("ERRO: Tentando iniciar uma wave enquanto ainda há inimigos!")
		return

	# Verifica se há uma wave disponível
	if not waves.has(current_wave):
		print("Todas as waves foram concluídas! Jogo encerrado.")
		emit_signal("game_end", false)  # Emite sinal de vitória
		return

	# Inicia a nova wave
	start_new_wave()
	print("Nova wave iniciada! Inimigos na cena:", active_enemies)




func retrieve_wave_data():
	var wave_data = []
	
	if not waves.has(current_wave):
		print("ERRO: Tentou acessar uma wave inexistente!", current_wave)
		return []  # Retorna uma lista vazia para evitar crash

	var wave_info = waves[current_wave]
	print("Recuperando dados da wave:", current_wave)

	for enemy_type in wave_info["enemies"]:
		var quantity = wave_info["enemies"][enemy_type]
		print("Inimigo:", enemy_type, "Quantidade:", quantity)
		for i in range(quantity):
			wave_data.append([enemy_type, wave_info["spawn_interval"]])

	total_enemies_in_wave = wave_data.size()  # Define o total de inimigos na wave
	print("Total de inimigos na wave:", total_enemies_in_wave)
	return wave_data

func spawn_enemies(wave_data):
	print("Spawnando inimigos...")

	for enemy in wave_data:
		var enemy_scene
		if enemy[0] == "airplane":  
			enemy_scene = load("res://Scenes/Enemies/airplane.tscn")
		else:  
			enemy_scene = load("res://Scenes/Enemies/%s.tscn" % [enemy[0]])
		if enemy_scene == null:
			print("Erro ao carregar cena do inimigo:", enemy[0])
			continue  
		var new_enemy = enemy_scene.instantiate()
		new_enemy.position = Vector2(-37, 609)  
		new_enemy.connect("life_damage", Callable(self, "life_base_damage"))
		new_enemy.connect("tree_exited", Callable(self, "_on_enemy_removed"))  # Conecta quando o inimigo morre
		print("Conectado sinal life_damage para:", enemy[0])
		print("Inimigo spawnado:", enemy[0])
		map_node.get_node('Path').add_child(new_enemy, true)
		
		# Atualiza o contador de inimigos
		active_enemies += 1  
		total_enemies_in_wave -= 1  # Diminui pois já foi spawnado!

		await get_tree().create_timer(enemy[1]).timeout  # Espera o intervalo do próximo spawn


var game_over_triggered = false  # Adicione essa variável no topo do script

func life_base_damage(damage):
	if game_over_triggered:
		return  # Evita chamar várias vezes

	print("Dano recebido na base:", damage)
	player_hp = max(player_hp - damage, 0)
	print("Nova vida do jogador:", player_hp)

	if player_hp <= 0 and not game_over_triggered:
		game_over_triggered = true
		print("Vida zerada. Encerrando jogo...")

		# Cancela qualquer processamento futuro antes de deletar a cena
		set_process(false)
		set_physics_process(false)

		var scene_handler = get_tree().get_root().find_child("SceneHandler", true, false)
		if scene_handler:
			queue_free()  # Remove a GameScene antes de ir ao menu
			await get_tree().process_frame  # Aguarda um frame para evitar conflitos
			scene_handler.load_main_menu()  
		else:
			print("Erro: SceneHandler não encontrado!")
	else:
		get_node('UI').update_hp_bar(player_hp)






func _on_enemy_removed():
	active_enemies -= 1
	#print("Inimigo removido Restantes:", active_enemies, "Total spawnados restantes:", total_enemies_in_wave)

	if active_enemies <= 0 and total_enemies_in_wave <= 0:
	#	print("Todos os inimigos foram derrotados")
		current_wave += 1  
		start_next_wave()
