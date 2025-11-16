extends Node2D

var star_scene = preload("res://scenes/star.tscn")

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
	else:
		$Imperfect.pitch_scale -= delta * 0.2
		$Imperfect.volume_db -= delta * 4
		
		if $Imperfect.pitch_scale < 0.3:
			$Imperfect.pitch_scale = 0.3
			
		if $Imperfect.volume_db < -32:
			$Imperfect.volume_db = -32
