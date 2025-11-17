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
	if $CanvasLayer/Control/Pause/VBoxContainer/HFlowContainer/GodMode.button_pressed:
		$Player.health = 1000
		
	if $CanvasLayer/Control/Pause/VBoxContainer/HFlowContainer/InfiniteBoost.button_pressed:
		$Player.boost = 100
	
	$UpGuide.global_position = $Player.global_position
	$UpGuide.rotation = (Vector2(0, 0) - $Player.global_position).normalized().angle() + rad_to_deg(90)
	
	$PointsOfInterest.rotation_degrees += delta * 0.03
	
	if $CanvasLayer/Control/Pause/VBoxContainer/HFlowContainer/FastOrbit.button_pressed:
		$PointsOfInterest.rotation_degrees += delta * 1
	
	$CanvasLayer/Control/InteractText.visible = false
	
	for n in $PointsOfInterest.get_children():
		if n.get_node("InteractArea").get_overlapping_bodies().has($Player):
			$CanvasLayer/Control/InteractText.visible = true
			if n.get_name() == "SpaceStation":
				$CanvasLayer/Control/InteractText.text = "press E to heal and refuel"
			if n.get_name() == "Sun":
				$CanvasLayer/Control/InteractText.text = "WARNING: RETREAT. CRITICAL HEAT!"
				if n.get_node("Killzone").get_overlapping_bodies().has($Player):
					$Player.health -= delta * 200
	
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
		
	$Player/Camera.offset = Vector2(randi_range(-camera_trauma, camera_trauma), randi_range(-camera_trauma, camera_trauma)) * $CanvasLayer/Control/Pause/Settings/VBoxContainer/ScreenShake.value
	
	var current_zone = null
	
	var distance = $Player.global_position.length()
	
	for n in zones:
		if distance > n.distance:
			current_zone = n
			
	$CanvasLayer/Control/ZoneText.text = current_zone.name + " - " + str(floorf(distance)) + "u"
	
	asteroid_quota = current_zone.asteroid_quota


func _on_new_enemy_pressed() -> void:
	var enemy = enemy_scene.instantiate()
	
	enemy.position = $Player.position + Vector2.UP.rotated($Player.rotation) * 1000
	
	$Enemies.add_child(enemy)


func _on_settings_pressed() -> void:
	$CanvasLayer/Control/Pause/Settings.visible = true


func _on_suicide_pressed() -> void:
	$Player.health = 0


func _on_space_station_pressed() -> void:
	$Player.global_position = $PointsOfInterest/SpaceStation.global_position


func _on_test_planet_pressed() -> void:
	$Player.global_position = $PointsOfInterest/TestPlanet.global_position
