extends Sprite2D

@onready var player = get_parent().get_parent().get_node("Player")

func random_respawn(distance_min = 2000):
	var random_rotation = randf_range(-7, 7)
	var random_distance = randi_range(distance_min, 2000)
	var random_size = randf_range(0.02, 0.5)
	
	global_position = player.global_position + (Vector2.UP.rotated(random_rotation) * random_distance)
	global_position += (Vector2.RIGHT  * randi_range(-random_distance, random_distance)).rotated(random_rotation)
	
	rotation = random_rotation
	
	scale.x = random_size
	scale.y = scale.x
	
func _ready() -> void:
	random_respawn(0)

func _process(delta: float) -> void:
	var distance = abs((player.global_position - global_position).length())
	
	if distance > 2100:
		random_respawn()
