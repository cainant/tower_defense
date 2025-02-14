extends Node2D

var enemy_array = []
var built = false
var tower_type
var enemy
var tower_ready = true

func _ready() -> void:
	if built:
		var radius = 0.5 * GameData.tower_info[tower_type]['range']
		self.get_node('Range/RangeShape').get_shape().radius = radius
		pass

func _physics_process(_delta: float) -> void:
	if built:
		if tower_type == "minigun_tier_1":
			if tower_ready:
				shoot()
		elif enemy_array.size() != 0:
			select_enemy()
			turn()
			if tower_ready:
				shoot()
	else:
		enemy = null

func turn():
	get_node("Turret").look_at(enemy.position)

func shoot():
	if tower_type == "minigun_tier_1":
		tower_ready = false
		var rof = GameData.tower_info[tower_type]["rate"]

		
		var projectile = preload("res://Scenes/bullet/projectile.tscn").instantiate()
		get_parent().add_child(projectile)

		
		projectile.position = global_position

		
		var mouse_pos = get_global_mouse_position()
		projectile.direction = (mouse_pos - global_position).normalized()

		projectile.damage = GameData.tower_info[tower_type]["damage"]

		
		await get_tree().create_timer(rof).timeout
		tower_ready = true
	else:
		tower_ready = false
		var damage = GameData.tower_info[tower_type]["damage"]
		enemy.on_take_damage(damage)

		var rof = GameData.tower_info[tower_type]["rate"]
		await get_tree().create_timer(rof).timeout

		tower_ready = true



func select_enemy() -> void:
	var enemy_progress_array = []
	for enemy in enemy_array:
		enemy_progress_array.append(enemy.progress)
	var max_progress = enemy_progress_array.max()
	var enemy_idx = enemy_progress_array.find(max_progress)
	enemy = enemy_array[enemy_idx]

func _on_range_body_entered(body: Node2D) -> void:
	enemy_array.push_back(body.get_parent())

func _on_range_body_exited(body: Node2D) -> void:
	enemy_array.erase(body.get_parent())
