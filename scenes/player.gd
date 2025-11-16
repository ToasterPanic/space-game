extends RigidBody2D

var health = 1000
var speed = 512
var boost = 100
var boosting = false
var angular_target = 0

var collision_cooldown = 0

var mouse_movement = Vector2()

var laser_scene = preload("res://scenes/laser.tscn")

@onready var game = get_parent()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	collision_cooldown -= delta 
	
	if Input.is_action_pressed("rotate_left"):
		angular_velocity = deg_to_rad(-120)
	if Input.is_action_pressed("rotate_right"):
		angular_velocity = deg_to_rad(120)
		
	if abs(angular_target) > 0.001:
		#angular_velocity = wrapf(angular_target - rotation, -PI, PI) * 6
		angular_velocity = angular_target * 6
	else:
		angular_velocity /= 1.4
	
	if Input.is_action_just_pressed("fire"):
		$Fire.pitch_scale = randf_range(0.9, 1.1)
		$Fire.play()
		
		var laser = laser_scene.instantiate()
		laser.creator = self 
		
		get_parent().add_child(laser)
		
		laser.global_position = global_position
		laser.rotation = rotation 
		
	$BoostParticles.emitting = boosting
	
	if boosting:
		if game.camera_trauma < 4:
			game.camera_trauma = 4
		linear_velocity = Vector2.UP.rotated(rotation) * 1024
		boost -= delta * 0
		if boost <= 0:
			boosting = false
			
		$Camera.zoom.x -= delta * 1
		
		if $Camera.zoom.x < 0.5:
			$Camera.zoom.x = 0.5
			
		$Camera.zoom.y = $Camera.zoom.x
		
	if Input.is_action_pressed("zoom"):
		$Camera.zoom.x -= delta * 1
		
		if $Camera.zoom.x < 0.5:
			$Camera.zoom.x = 0.5
			
		$Camera.zoom.y = $Camera.zoom.x
			
	elif Input.is_action_pressed("move_forward") and not boosting:
		linear_velocity = Vector2.UP.rotated(rotation) * speed
	#if Input.is_action_pressed("move_backward"):
		#linear_velocity = Vector2.UP.rotated(rotation) * (speed * -0.5)
	if Input.is_action_just_pressed("speed_up"):
		speed += 16
		
		if speed > 512:
			speed = 512
			
		$Speed.value = speed
		$Speed.modulate = Color(1,1,1,1)
		$Speed/Label.text = str(floori(speed)) + "\nm/s"
	if Input.is_action_just_pressed("speed_down"):
		speed -= 16
		
		if speed < 0:
			speed = 0
			
		$Speed.value = speed
		$Speed/Label.text = str(floori(speed)) + "\nm/s"
		$Speed.modulate = Color(1,1,1,1)
		
	if Input.is_action_just_pressed("boost") and (boost > 33):
		boosting = true
		$BoostSound.play()
	elif Input.is_action_just_released("boost"):
		boosting = false
		
	if not boosting:
		$BoostSound.stop()
		
		boost += delta * 10
		if boost > 100:
			boost = 100
			
		if not Input.is_action_pressed("zoom"):
			$Camera.zoom.x -= ($Camera.zoom.x - 0.666) * 0.4
			$Camera.zoom.y = $Camera.zoom.x
		
	$Speed.modulate.a -= 0.5 * delta
	
	$Boost.modulate.a -= 0.5 * delta
	
	if boost < 99:
		$Boost.modulate = Color(1,1,1,1)
		
	$Boost.value = boost
	$Boost/Label.text = str(ceili(boost))
		
	modulate = Color(1, health / 1000.0, health / 1000.0)

func _on_body_entered(body: Node) -> void:
	if collision_cooldown > 0: return 
	
	if body.get_parent().get_name() == "Asteroids":
		if body.linear_velocity.length() + linear_velocity.length() > 128:
			$Collision.pitch_scale = randi_range(0.7, 0.9)
			$Collision.play()
				
			game.camera_trauma += 16
			
			health -= body.linear_velocity.length() / 2.5
			
			collision_cooldown = 0.3
			
	if body.get_parent().get_name() == "Enemies":
		if body.linear_velocity.length() + linear_velocity.length() > 400:
			$Collision.pitch_scale = randi_range(0.3, 0.4)
			$Collision.play()
			
			collision_cooldown = 0.3
			
			game.camera_trauma += 4
			if body.linear_velocity.length() + linear_velocity.length() > 1024 + 524:
				game.camera_trauma += 12
				
				health -= ((body.linear_velocity.length() + linear_velocity.length()) / 3) * (linear_velocity.length() / body.linear_velocity.length())
				body.health -= ((body.linear_velocity.length() + linear_velocity.length()) / 6) * (body.linear_velocity.length() / linear_velocity.length())
				
				

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		angular_target = mouse_movement.x / 64
