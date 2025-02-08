extends CanvasLayer

@onready var hp_bar = get_node("HUD/Status_bar/Hbox_container/Hp_bar")


var red_color = Color(0.863, 0, 0.031, 0.75)
var green_color = Color(0, 0.615, 0.268, .95)

func set_tower_preview(build_type: String, mouse_position: Vector2):
	var drag_tower = load('res://Scenes/Turrets/' + build_type + '.tscn').instantiate()
	drag_tower.set_name('DragTower')
	drag_tower.modulate = green_color
	
	var scaling = GameData.tower_info[build_type]['range'] / 600.0
	var range_texture = Sprite2D.new()
	range_texture.name = ('RangeTexture')
	range_texture.scale = Vector2(scaling, scaling)
	range_texture.texture = load("res://Assets/UI/range_overlay.png")
	range_texture.modulate = Color(1, 1, 1, 0.8)
	
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.global_position = mouse_position
	control.set_name('TowerPreview')
	
	self.add_child(control, true)
	self.move_child(control, 0)

func update_tower_preview(tile_pos: Vector2, build_valid: bool):
	var tower_preview = get_node('TowerPreview')
	tower_preview.global_position = tile_pos
	
	get_node('TowerPreview/DragTower').modulate = green_color if build_valid else red_color
	get_node('TowerPreview/RangeTexture').modulate = green_color if build_valid else red_color

func update_hp_bar(player_hp):
	var hp_bar_tween = create_tween()
	hp_bar_tween.tween_property(hp_bar, "value", player_hp, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	#search for godot tween cheat sheet to understand better transistion_type and easing type

func _on_pause_play_pressed() -> void:
	if self.get_parent().build_mode:
		self.get_parent().cancel_build_mode()
	if self.get_tree().is_paused():
		self.get_tree().paused = false
	elif self.get_parent().current_wave == 0:
		get_parent().current_wave = 1
		get_parent().start_new_wave()
	else:
		self.get_tree().paused = true


func _on_fast_foward_pressed() -> void:
	Engine.set_time_scale(1.0 if Engine.get_time_scale() == 2.0 else 2.0)
	
