extends RigidBody2D

var creator = null
var time = 0
var enabled = true

func _process(delta: float) -> void:
	time += delta
	
	linear_velocity = Vector2.UP.rotated(rotation) * 2048
	
	if time > 5:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if not enabled:
		return
		
	if body == creator:
		return
	
	if "health" in body:
		enabled = false
			
		body.health -= 100
		$Sprite.visible = false
		
		$Particles.emitting = true
