extends Node2D

var center_position: Vector2 = Vector2(500, 500)  
var orbit_radius: float = 150  
var speed: float = 20  
var angle: float = 0.0  
var target_tower = null  
var damage: int = 20  
var damage_interval: float = 5.0  
var damage_timer: float = 0.0  
var hp: int = 50  
var max_hp: int = 50  

signal life_damage(damage)

@onready var hp_bar = $hp_bar  

func _ready():
	
	hp_bar.max_value = max_hp  
	hp_bar.value = hp          

func _process(delta):
	if target_tower and not is_instance_valid(target_tower):
		target_tower = null  

	if target_tower:
		orbit_tower(delta)
	else:
		patrol_map(delta)

func on_take_damage(amount: int):
	#print("Avião tomou dano:", amount)  
	hp = max(hp - amount, 0)
	hp_bar.value = hp  

	if hp == 0:
		on_destroyed()
		on_killed()

func on_killed() -> void:
	var game_scene = get_tree().get_root().find_child("SceneHandler", true, false).find_child("GameScene", true, false)
	if game_scene:
		game_scene.player_money += 20
		game_scene.update_money_display()
	queue_free()


func on_destroyed():
	queue_free()  


func patrol_map(delta):
	angle += speed * delta * 0.05  
	if angle >= TAU:
		angle -= TAU

	var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
	global_position = center_position + offset

	
	find_nearest_tower()


func _on_body_entered(body):
	if body.is_in_group("enemies"):  
		if body.has_method("take_damage"):
			body.take_damage(damage)  
		queue_free()  



func find_nearest_tower():
	var towers = get_tree().get_nodes_in_group("towers")
	if towers.size() == 0:
		return

	var closest_tower = null
	var min_distance = INF
	
	for tower in towers:
		var distance = global_position.distance_to(tower.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_tower = tower
	
	if closest_tower:
		target_tower = closest_tower
		#print("Nova torre alvo detectada:", target_tower)



func orbit_tower(delta):
	if target_tower:
		
		center_position = target_tower.global_position  

		angle += speed * delta * 0.05  
		if angle >= TAU:
			angle -= TAU
			apply_damage_to_tower()  

		var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
		global_position = center_position + offset

func apply_damage_to_tower():
	if target_tower and target_tower.has_method("take_damage"):
		target_tower.take_damage(damage)
		#print("Dano aplicado à torre HP restante: ", target_tower.hp)
