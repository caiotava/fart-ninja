extends CharacterBody2D

@export_group("Movement")
@export var movement_speed: float = 200.0
@export var movement_target_position: Vector2 = Vector2(60.0,180.0)
@export var movement_path_length : float = 1920
@export var is_paused : bool = false
@export var pause_time_limit : float = 1.5
@export var pause_likelihood : float = 0.2

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer : Timer = $Timer

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	timer.wait_time = pause_time_limit

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(get_random_position())

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		handle_pause()
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	animation_sprite.play("walking")
	
	# has collision
	if move_and_slide():
		is_paused = true
		animation_sprite.stop()

func _process(delta):
	process_pause(delta)

func process_pause(delta):
	if !is_paused:
		return

	if timer.is_stopped():
		timer.start()

func get_random_position():
	return Vector2(randf_range(300, 1800), randf_range(230, 920))

func handle_pause():
	if is_paused:
		return

	var rand_number = randf_range(0, 1)
	if rand_number < pause_likelihood:
		is_paused = true
		animation_sprite.stop()

func _on_timer_timeout():
	is_paused = false;
	set_movement_target(get_random_position())