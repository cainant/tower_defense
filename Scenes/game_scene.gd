extends Node2D

var map_node

func _ready():
	map_node = get_node('Map1')
	
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
		var new_tower = load('res://Scenes/Turrets/' + build_type + '.tscn').instantiate()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.tower_type = build_type
		map_node.get_node('Towers').add_child(new_tower, true)
		map_node.get_node('TowerExclusion').set_cell(build_tile, 0, Vector2i(0, 1))
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node('UI/TowerPreview').free()


##
## Wave functions
##
var current_wave = 0
var enemies_in_wave

func start_new_wave():
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout
	spawn_enemies(wave_data)
	
func retrieve_wave_data():
	var wave_data = [['blue_tank', 3.0], ['blue_tank', 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	
	return wave_data
	
func spawn_enemies(wave_data):
	for enemy in wave_data:
		var new_enemy = load("res://Scenes/Enemies/%s.tscn" % [enemy[0]]).instantiate()
		map_node.get_node('Path').add_child(new_enemy, true)
		await get_tree().create_timer(enemy[1]).timeout
	
	
