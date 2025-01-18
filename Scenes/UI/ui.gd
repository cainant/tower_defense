extends CanvasLayer

var red_color = Color(0.863, 0, 0.031, 0.75)
var green_color = Color(0, 0.615, 0.268, 0.75)

func set_tower_preview(build_type: String, mouse_position: Vector2):
	var drag_tower = load('res://Scenes/Turrets/' + build_type + '.tscn').instantiate()
	drag_tower.set_name('DragTower')
	
	var control = Control.new()
	control.modulate = green_color
	control.add_child(drag_tower, true)
	control.global_position = mouse_position
	control.set_name('TowerPreview')
	add_child(control, true)
	move_child(control, 0)

func update_tower_preview(tile_pos: Vector2, build_valid: bool):
	var tower_preview = get_node('TowerPreview')
	tower_preview.global_position = tile_pos
	tower_preview.modulate = green_color if build_valid else red_color
