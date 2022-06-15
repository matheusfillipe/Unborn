extends KinematicBody2D

onready var playerdetect = $PlayerDetect
onready var wandercontroller = $WanderController

export var ACCELERATION = 100
export var MAX_SPEED = 50
export var FRICTION = 200


enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var state = WANDER
var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			update_wander()
			
		WANDER:
			seek_player()
			update_wander()
			accelerate_towards_point(wandercontroller.target_position, delta)
			if global_position.distance_to(wandercontroller.target_position) <= MAX_SPEED * delta:
				update_wander()
		CHASE:
			var player = playerdetect.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	velocity = move_and_slide(velocity)


func update_wander():
	if wandercontroller.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wandercontroller.start_wander_timer(rand_range(1, 3))

func seek_player():
	if playerdetect.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	$Sprite.flip_h = velocity.x < 0

