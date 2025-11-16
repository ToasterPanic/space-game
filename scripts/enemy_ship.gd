extends RigidBody2D

@onready var player = get_parent().get_parent().get_node("Player")

var laser_scene = preload("res://scenes/laser.tscn")
var health = 500
var speed = 512
var boost = 100

var boosting = false

var angle_to_fire = 20
var concentration = 5
var fire_rate = 0.5

var MODE_WANDER = 0
var MODE_ATTACK = 1
var MODE_FLEE = 2

var mode = MODE_WANDER

var fire_cooldown = 0

var evading = false
var evasion_direction = 1
var evasion_direction_switch_time = 1

var dead = false

var catchup_boost = false
var boost_cooldown = false

func _process(delta: float) -> void:
	if dead: return
	
	var angular_target = 0
	var boosting = false
	
	if health < 200:
		mode = MODE_FLEE
	
	if mode == MODE_ATTACK:
		var direction = (player.position - position).normalized()

		# Optionally, you can get the angle if needed
		var angle = direction.angle() + deg_to_rad(90)
		
		angular_target = wrapf(angle - rotation, -PI, PI)
		
		if abs(rad_to_deg(angular_target)) < angle_to_fire:
			fire_cooldown += delta
			if fire_cooldown > fire_rate:
				fire_cooldown = 0
				$Fire.pitch_scale = randf_range(0.7, 0.8)
				$Fire.volume_db = -(player.position - position).length() * 0.01
				print($Fire.volume_db)
				$Fire.play()
		
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
			if false and ((player.position - position).length() > 480) and (abs(rad_to_deg(player_angular_target)) < 180):
				angular_target -= deg_to_rad(180 - 30)
			else:
				angular_target -= deg_to_rad(90 * evasion_direction)
				evasion_direction_switch_time -= delta
				boosting = true
				
			if evasion_direction_switch_time <= 0:
				evasion_direction_switch_time = randf_range(1.75, 2.1)
				evasion_direction *= -1
				
			concentration = 9
			if abs(rad_to_deg(player_angular_target)) > angle_to_fire * 3:
				evading = false
				concentration = 5
		elif (player.position - position).length() < 128:
			angular_target -= deg_to_rad(90 * evasion_direction)
			evasion_direction_switch_time -= delta
		elif (boost > 99) and ((player.position - position).length() > 380):
			catchup_boost = true
			
		if catchup_boost:
			if (boost < 70) or ((player.position - position).length() < 320):
				catchup_boost = false
				boosting = false
			else:
				boosting = true
		
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
		
		if abs(rad_to_deg(player_angular_target)) < angle_to_fire:
			angular_target += deg_to_rad(45 * evasion_direction)
			boosting = true
			
		if (player.position - position).length() < 128:
			angular_target -= deg_to_rad(90)
		
		if health <= 100:
			boosting = true
	else:
		for n in $Sight.get_overlapping_bodies():
			if n == player:
				mode = MODE_ATTACK
		
	if abs(angular_target) > 0.1:
		angular_velocity = angular_target * concentration
	else:
		angular_velocity /= 1.4
	
	$BoostParticles.emitting = boosting
	
	if boosting and (boost > 0) and not boost_cooldown:
		linear_velocity = Vector2.UP.rotated(rotation) * 1024
		boost -= delta * 50
	else:
		linear_velocity = Vector2.UP.rotated(rotation) * speed
		boost += delta * 10
		
		if boost >= 33:
			boost_cooldown = false
		
	modulate = Color(1, health / 500.0, health / 500.0)
	
	if health <= 0:
		dead = true
		
		linear_velocity = Vector2()
		$CollisionShape2D.queue_free()
		$Sprite.queue_free()
		$BoostParticles.queue_free()
		mode = INF
		
		$Explode.play()
		
		modulate = Color(1, 1, 1)
		
		for n in $ExplosionParticles.get_children():
			n.restart()
		
		await get_tree().create_timer(4).timeout
		
		queue_free()
	
	#rotation = angle
