extends Area2D

var speed = 800
var direction = Vector2.ZERO  
var damage = 0  

func _process(delta):
	position += direction * speed * delta


func _ready():
	connect("body_entered", _on_body_entered)

	$CollisionShape2D.set_deferred("disabled", false)
	monitoring = true
	monitorable = true
	$Timer.start(1)





func _on_body_entered(body):
	var enemy = body.get_parent()  
	#print("Projétil colidiu com:", enemy)  # <-- Adiciona um print para debug

	if enemy and enemy.has_method("on_take_damage"):  
		#print("Inimigo válido! Aplicando dano.")
		enemy.on_take_damage(damage)
		queue_free()  
	else:
		print("O corpo atingido não possui 'on_take_damage'.")





func _on_timer_timeout():
	call_deferred("queue_free")
