extends PathFollow2D

signal life_damage(damage)

var speed = 150
var hp = 50
var life_damage_value = 50
var is_frozen: bool = false
var freeze_timer: Timer

@onready var hp_bar = get_node("hp_bar")

func _ready():
	hp_bar.max_value = hp
	hp_bar.value = hp
	
	# Criar e configurar o timer para o congelamento
	freeze_timer = Timer.new()
	freeze_timer.wait_time = 0
	freeze_timer.one_shot = true
	freeze_timer.timeout.connect(_on_freeze_end)
	add_child(freeze_timer)
	
	# Adicionar ao grupo de inimigos
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if not is_frozen:
		move(delta)
	check_end_path()

func move(delta):
	self.set_progress(self.get_progress() + speed * delta)
	
func check_end_path() -> void:
	if progress_ratio >= 1.0:
		handle_reach_end()

func handle_reach_end() -> void:
	life_damage.emit(life_damage_value)
	queue_free()

func on_take_damage(damage: int) -> void:
	hp = max(hp - damage, 0)
	hp_bar.value = hp
	if hp == 0:
		on_killed()

func on_killed() -> void:
	var game_scene = get_tree().get_root().find_child("SceneHandler", true, false).find_child("GameScene", true, false)
	if game_scene:
		game_scene.player_money += 20
		game_scene.update_money_display()
		
		if randf() < 0.1:
			var freeze_scene = load("res://Scenes/PowerUps/freeze.tscn")  
			var freeze_instance = freeze_scene.instantiate()
			freeze_instance.position = position
			game_scene.add_child(freeze_instance)

	queue_free()


# Função para congelar o inimigo
func freeze(duration: float):
	if is_frozen:
		return
	is_frozen = true
	freeze_timer.wait_time = duration
	freeze_timer.start()

func _on_freeze_end():
	is_frozen = false
