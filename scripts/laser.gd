extends RigidBody2D

var creator = null
var time = 0

func _process(delta: float) -> void:
	time += delta
	
	linear_velocity = Vector2.UP.rotated(rotation) * 1024
	
	if time > 5:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if "health" in body:
		if body == creator:
			return
			
		body.health -= 100
		queue_free()
