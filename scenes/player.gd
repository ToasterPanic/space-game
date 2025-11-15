extends RigidBody2D

var health = 1000
var speed = 512
var angular_target = 0

var mouse_movement = Vector2()

var laser_scene = preload("res://scenes/laser.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_pressed("rotate_left"):
		angular_velocity = deg_to_rad(-120)
	if Input.is_action_pressed("rotate_right"):
		angular_velocity = deg_to_rad(120)
		
	if abs(angular_target) > 0.001:
		angular_velocity = wrapf(angular_target - rotation, -PI, PI) * 6
	else:
		angular_velocity /= 1.4
	
	if Input.is_action_just_pressed("fire"):
		var laser = laser_scene.instantiate()
		laser.creator = self 
		
		get_parent().add_child(laser)
		
		laser.global_position = global_position
		laser.rotation = rotation 
		
	if Input.is_action_pressed("move_forward"):
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
		
	$Speed.modulate.a -= 0.5 * delta
		
	modulate = Color(1, health / 1000.0, health / 1000.0)

func _on_body_entered(body: Node) -> void:
	if body.get_parent().get_name() == "Asteroids":
		if body.linear_velocity.length() > 120:
			health -= body.linear_velocity.length() / 7

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		angular_target += mouse_movement.x / 64
