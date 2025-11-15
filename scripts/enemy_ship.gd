extends RigidBody2D

@onready var player = get_parent().get_node("Player")

var laser_scene = preload("res://scenes/laser.tscn")
var health = 500
var angle_to_fire = 20
var concentration = 5
var fire_rate = 0.5

var MODE_WANDER = 0
var MODE_ATTACK = 1
var MODE_FLEE = 2

var mode = MODE_ATTACK

var fire_cooldown = 0

var evading = false
var evasion_direction = 1
var evasion_direction_switch_time = 1

func _process(delta: float) -> void:
	
	var angular_target = 0
	var boosting = false
	
	if health < 200:
		mode = MODE_FLEE
	
	if mode == MODE_ATTACK:
		var direction = (player.position - position).normalized()

		# Optionally, you can get the angle if needed
		var angle = direction.angle() + deg_to_rad(90)
		
		angular_target = wrapf(angle - rotation, -PI, PI)
		
		if abs(rad_to_deg(angular_target)) < 20:
			fire_cooldown += delta
			if fire_cooldown > fire_rate:
				fire_cooldown = 0
				var laser = laser_scene.instantiate()
				laser.creator = self 
				
				get_parent().add_child(laser)
				
				laser.global_position = global_position
				laser.rotation = rotation
		
		# Evasion
		
		var player_direction = (position - player.position).normalized()

		# Optionally, you can get the angle if needed
		var player_angle = player_direction.angle() + deg_to_rad(90)
		
		var player_angular_target = wrapf(player_angle - player.rotation, -PI, PI)
		
		if abs(rad_to_deg(player_angular_target)) < angle_to_fire * 1.5:
			evading = true
			
			
		
			
		if evading:
			if (player.position - position).length() > 360:
				if evasion_direction > 0:
					angular_target -= deg_to_rad(180 - 30)
				angular_target += deg_to_rad(180)
				evasion_direction_switch_time -= delta
			else:
				angular_target -= deg_to_rad(30 * evasion_direction)
				boosting = true
				
			if evasion_direction_switch_time <= 0:
				evasion_direction_switch_time = randi_range(1.0, 1.0)
				evasion_direction *= -1
				
			concentration = 9
			if abs(rad_to_deg(player_angular_target)) > angle_to_fire * 4:
				evading = false
				concentration = 5
		elif (player.position - position).length() < 128:
			angular_target -= deg_to_rad(90)
		
		print(player_angular_target)
	elif mode == MODE_FLEE:
		var direction = (player.position - position).normalized()

		# Optionally, you can get the angle if needed
		var angle = direction.angle() + deg_to_rad(270)
		
		angular_target = wrapf(angle - rotation, -PI, PI)
			
		# Evasion
		
		concentration = 3
		
		var player_direction = (position - player.position).normalized()

		# Optionally, you can get the angle if needed
		var player_angle = player_direction.angle() + deg_to_rad(90)
		
		var player_angular_target = wrapf(player_angle - player.rotation, -PI, PI)
		
		if abs(rad_to_deg(player_angular_target)) < 5:
			angular_target += deg_to_rad(45)
			boosting = true
			
		if (player.position - position).length() < 128:
			angular_target -= deg_to_rad(90)
		
		if health <= 100:
			boosting = true
		
	if abs(angular_target) > 0.1:
		angular_velocity = angular_target * concentration
	else:
		angular_velocity /= 1.4
		
	linear_velocity = Vector2.UP.rotated(rotation) * 360
	if boosting:
		linear_velocity *= 2
		
	modulate = Color(1, health / 500.0, health / 500.0)
	
	if health <= 0:
		queue_free()
	
	#rotation = angle
