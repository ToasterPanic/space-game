extends RigidBody2D

@onready var game = get_parent().get_parent()
@onready var player = game.get_node("Player")
var type = "Small"
var health = 500
var dead = false

func random_respawn(distance_min = 2000):
	var random_rotation = randf_range(-5, 5)
	var random_distance = randi_range(distance_min, 2000)
	
	global_position = player.global_position + (Vector2.UP.rotated(random_rotation) * random_distance)
	global_position += (Vector2.RIGHT  * randi_range(-random_distance, random_distance)).rotated(random_rotation)
	linear_velocity = Vector2(randi_range(-256, -192), randi_range(-128, 128))
	
func _ready() -> void:
	var random_type = randi_range(1, 10)
	if random_type > 9:
		type = "Large"
	elif random_type > 6:
		type = "Medium"
		
	for n in get_children():
		if n.is_class("CollisionShape2D"):
			if n.get_name() != type:
				n.queue_free()
		
	random_respawn()

func _process(delta: float) -> void:
	if dead:
		return
		
	modulate = Color(1, health / 500.0, health / 500.0)
	
	if linear_velocity.x > -64:
		linear_velocity.x -= delta * 16
	var distance = abs((player.global_position - global_position).length())
	
	if distance > 2100:
		if game.asteroid_quota < get_parent().get_child_count():
			queue_free()
			return
			
		if game.asteroid_quota > get_parent().get_child_count():
			var extra_asteroids_needed = game.asteroid_quota - get_parent().get_child_count()
			
			var i = 0 
			while i < extra_asteroids_needed:
				var new_asteroid = game.asteroid_scene.instantiate()
				get_parent().add_child(new_asteroid)
			
				i += 1
			
		random_respawn()
		
	if health <= 0:
		dead = true
		
		linear_velocity = Vector2()
		for n in get_children():
			if n.get_name() != "ExplosionParticles": n.queue_free()
		
		modulate = Color(1, 1, 1)
		
		for n in $ExplosionParticles.get_children():
			n.restart()
		
		await get_tree().create_timer(4).timeout
		
		queue_free()
