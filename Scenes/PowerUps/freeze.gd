extends Node2D

@export var freeze_duration: float = 3.0

func _ready():
	$Area2D.input_event.connect(_on_power_up_clicked)

func _on_power_up_clicked(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		apply_freeze_effect()
		queue_free()

func apply_freeze_effect():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.freeze(freeze_duration)
