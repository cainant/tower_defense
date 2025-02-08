extends PathFollow2D

signal life_damage(damage)

var speed = 150
var hp = 50
var life_damage_value = 50

@onready var hp_bar = get_node("hp_bar")

func _ready():
	hp_bar.max_value = hp
	hp_bar.value = hp
	
func _physics_process(delta: float) -> void:
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
	queue_free()
