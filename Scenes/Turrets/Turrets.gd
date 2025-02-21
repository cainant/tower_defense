extends Node2D

var enemy_array = []
var built = false
var tower_type
var enemy
var tower_ready = true
var hp: int = 100  # Vida da torre
var max_hp: int = 100  # Vida máxima

@onready var hp_bar = get_node("hp_bar")  # Referência à barra de vida



func _ready():
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp

	if built:
		var radius = 0.5 * GameData.tower_info[tower_type]['range']
		self.get_node('Range/RangeShape').get_shape().radius = radius
		pass

func take_damage(amount: int):
	hp = max(hp - amount, 0)
	if hp_bar:
		hp_bar.value = hp  # Atualiza a barra de vida

	if hp == 0:
		on_destroyed()


func on_destroyed():
	queue_free()  # Remove a torre da cena



func _physics_process(delta: float) -> void:
	if built:
		if tower_type == "minigun_tier_1":
			if tower_ready:
				shoot()
		elif enemy_array.size() != 0:
			select_enemy()
			if enemy != null:  # Verifica se enemy não é null
				turn()
				if tower_ready:
					shoot()
	else:
		enemy = null

func turn():
	if enemy != null:
		get_node("Turret").look_at(enemy.position)
#	else:
#		print("Nenhum inimigo definido. Não é possível virar a torre.")

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
	var valid_enemies = []
	for enemy in enemy_array:
		if enemy.has_method("get_progress"):  # Verifica se o inimigo tem a propriedade progress
			valid_enemies.append(enemy)
	
	if valid_enemies.size() > 0:
		var enemy_progress_array = []
		for enemy in valid_enemies:
			enemy_progress_array.append(enemy.progress)
		
		var max_progress = enemy_progress_array.max()
		var enemy_idx = enemy_progress_array.find(max_progress)
		enemy = valid_enemies[enemy_idx]
	else:
		enemy = null  # Define enemy como null se nenhum inimigo for encontrado
		#print("Nenhum inimigo válido encontrado em enemy_array.")

func _on_range_body_entered(body: Node2D) -> void:
	enemy_array.push_back(body.get_parent())

func _on_range_body_exited(body: Node2D) -> void:
	enemy_array.erase(body.get_parent())
