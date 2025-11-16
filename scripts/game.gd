extends Node2D

var star_scene = preload("res://scenes/star.tscn")

var enemy_scene = preload("res://scenes/enemy_ship.tscn")

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var asteroid_quota = 0

var camera_trauma = 0

var paused = false

var zones = [
	{
		"name": "THE STAR",
		"asteroid_quota": 1,
		"distance": -INF
	},
	{
		"name": "DEBRIS ZONE",
		"asteroid_quota": 15,
		"distance": 7500
	},
	{
		"name": "ASTEROID BELT",
		"asteroid_quota": 128,
		"distance": 13000
	},
	{
		"name": "DEBRIS ZONE II",
		"asteroid_quota": 15,
		"distance": 25000
	},
	{
		"name": "PLEASANT ORBIT",
		"asteroid_quota": 128,
		"distance": 50000
	},
]

func _ready() -> void:
	var i = 0
	while i < 360:
		var star = star_scene.instantiate()
		
		$Stars.add_child(star)
		
		i += 1

func _process(delta: float) -> void:
	var player_targeted = false
	
	for n in $Enemies.get_children():
		if "mode" in n:
			if n.mode == n.MODE_ATTACK:
				player_targeted = true 
				
	if player_targeted:
		$Imperfect.pitch_scale += delta * 0.333
		$Imperfect.volume_db += delta * 4
		
		if $Imperfect.pitch_scale > 1:
			$Imperfect.pitch_scale = 1
			
		if $Imperfect.volume_db > -12:
			$Imperfect.volume_db = -12
		
		$CanvasLayer/Control/CombatInitiated.modulate = Color(1,1,1)
	else:
		$Imperfect.pitch_scale -= delta * 0.2
		$Imperfect.volume_db -= delta * 4
		
		if $Imperfect.pitch_scale < 0.3:
			$Imperfect.pitch_scale = 0.3
			
		if $Imperfect.volume_db < -32:
			$Imperfect.volume_db = -32
			
		$CanvasLayer/Control/CombatInitiated.modulate.a -= delta * 34
		
	camera_trauma -= delta * 32
	
	if camera_trauma < 0:
		camera_trauma = 0
		
	$Player/Camera.offset = Vector2(randi_range(-camera_trauma, camera_trauma), randi_range(-camera_trauma, camera_trauma))
	
	var current_zone = null
	
	for n in zones:
		if $Player.global_position.y > n.distance:
			current_zone = n
			
	$CanvasLayer/Control/ZoneText.text = current_zone.name + " - " + str(floorf($Player.global_position.y)) + "u"
	
	asteroid_quota = current_zone.asteroid_quota


func _on_new_enemy_pressed() -> void:
	var enemy = enemy_scene.instantiate()
	
	enemy.position = $Player.position + Vector2.UP.rotated($Player.rotation) * 1000
	
	$Enemies.add_child(enemy)
