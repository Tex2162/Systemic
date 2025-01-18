extends CharacterBody3D


#variables n shit
var speed = 15
const JUMP_VELOCITY = 4.5
var acceleration = 2.5
var friction = 5
var if_moving = false
var SENSITIVITY = 0.003
var max_speed = 28

#referencees to de head, etc.
@onready var camera = $Node3D/Camera3D
@onready var head = $Node3D
@onready var label = $Label
@onready var label2 = $Label2

#captures the mouse
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#WE GOT ACCELERATOIN AND DECCELERATION BOIIIIIII
func _process(delta: float) -> void:
	if if_moving:
		speed += acceleration  / friction * delta
		if speed >= max_speed:
			speed = max_speed
	else:
		speed = 15 * delta 
		if speed < 15: 
			speed = 15

	label.text = "Speed: %.2f" % speed

#if you dislike being able to look around you're an idiot and also this is what allows that

#or yk just set the sensitivity to like zero
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		if is_on_floor():
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		else:
			pass

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("Crouch"):
		scale.y = 0.5
	else:
		scale.y = 1
		
	# Get the input direction
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if_moving = true
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			if_moving = false
		
		#stuff for like camera sway
		if input_dir.x>0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-3), 0.06)
		elif input_dir.x<0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(3), 0.06)
		else:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), 0.05)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
		
		
	
	# Move the character
	move_and_slide()
	
