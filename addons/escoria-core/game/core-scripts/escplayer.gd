tool
extends KinematicBody2D
class_name ESCPlayer

func get_class():
	return "ESCPlayer"

"""
TODO
- Currently the sprite node needs to be named "sprite". This is bad.
- Animation management doesn't allow using AnimationPlayer yet. Need to find 
	the best solution to manage both AnimatedSprite and AnimationPlayer.
"""

var Movable : Node
var MovableScript = load("res://addons/escoria-core/game/core-scripts/behaviors/movable.gd")

export var global_id : String

var params_queue : Array 
var terrain : ESCTerrain
var camera : ESCCamera

# If the terrain node type is scalenodes
var terrain_is_scalenodes : bool
var check_maps = true

var walk_path : Array = []
var walk_destination : Vector2
var walk_context
var target_object : Object = null
var moved : bool
var path_ofs : float 

export(int) var speed : int = 300
export(float) var v_speed_damp : float = 1.0
var orig_speed : float

enum PLAYER_TASKS {
	NONE,
	WALK,
	SLIDE
}
var task # type PLAYER_TASKS

# State machine defining the current interact state of the player
enum INTERACT_STATES {
	INTERACT_STARTED,	# 
	INTERACT_NONE,		#
	INTERACT_WALKING	# Player is walking
}
var interact_status		# Current interact status, type INTERACT_STATES


enum Directions {
	NORTH = 0, 		# 0
	NORTHEAST = 1, 	# 1
	EAST = 2, 		# 2
	SOUTHEAST = 3, 	# 3
	SOUTH = 4, 		# 4
	SOUTHWEST = 5, 	# 5
	WEST = 6,	 	# 6
	NORTHWEST = 7, 	# 7
	TOP = 0,
	TOP_RIGHT = 1
	RIGHT = 2,
	BOTTOM_RIGHT = 3,
	BOTTOM = 4,
	BOTTOM_LEFT = 5,
	LEFT = 6,
	TOP_LEFT = 7,
}

var last_deg : int
var last_dir : int
var last_scale : Vector2
var pose_scale : int

# Animations script (for walking, idling...)
export(Script) var animations

# AnimatedSprite node (if any)
var animation_sprite
# AnimationPlayer node (if any)
## NOT USED YET
#var animation
var collision

# Dialogs parameters
export(NodePath) var dialog_position_node
export(Color) var dialog_color = ColorN("white")

# Camera parameters
export(NodePath) var camera_position_node


func _ready():
	# Adds movable behavior
	Movable = Node.new()
	Movable.set_script(MovableScript)
	add_child(Movable)
	
	
	# Connect the player to the event_done signal, so we can react to a finished 
	# ":setup" event. In this case, we need to run update_terrain()
	escoria.esc_runner.connect("event_done", Movable, "update_terrain")
	
#	assert(is_angle_in_interval(0, [340,40])) # true
#	assert(is_angle_in_interval(359, [340,40])) # true
#	assert(is_angle_in_interval(1, [340,40])) # true
#	assert(!is_angle_in_interval(90, [340,40])) # false
#
#	assert(is_angle_in_interval(90, [70,40])) #true
#	assert(!is_angle_in_interval(180, [70,40])) #false
#
#	assert(is_angle_in_interval(179, [160, 40])) #true
#	assert(is_angle_in_interval(180, [160, 40])) #true
#	assert(is_angle_in_interval(181, [160, 40])) #true
#	assert(!is_angle_in_interval(0, [160, 40])) #false
#
#	assert(is_angle_in_interval(270, [250, 40])) # true
#	assert(!is_angle_in_interval(270, [70,40])) #false
	
	for n in get_children():
		if n is AnimatedSprite:
			animation_sprite = n
			
#			for sprite_child in n.get_children():
#				if sprite_child is AnimationPlayer:
#					animation = sprite_child
#					break
		
		if n is CollisionShape2D or n is CollisionPolygon2D:
			collision = n
	
	animation_sprite.connect("animation_finished", self, "anim_finished")
	
	if Engine.is_editor_hint():
		return
	
	terrain = escoria.room_terrain
	last_scale = scale
	
	set_process(true)


func _process(time):
	if Engine.is_editor_hint():
		return
	$debug.text = str(z_index)


"""
Sets player angle and plays according animation.
- deg int angle to set the character 
- immediate bool (currently unused, see TODO below)
	If true, direction is switched immediately. Else, successive animations are
	used so that the character turns to target angle. 

TODO: depending on current angle and current angle, the character may directly turn around
with no "progression". We may enhance this by calculating successive directions to turn the
character to, so that he doesn't switch to opposite direction too fast.
For example, if character looks WEST and set_angle(EAST) is called, we may want the character
to first turn SOUTHWEST, then SOUTH, then SOUTHEAST and finally EAST, all more or less fast. 
Whatever the implementation, this should be activated using "parameter "immediate" set to false.
"""
func set_angle(deg : int, immediate = true):
	if deg < 0 or deg > 360:
			escoria.report_errors("escplayer.gd:set_angle()", ["Invalid degree to turn to " + str(deg)])
	moved = true
	last_deg = deg
	last_dir = Movable._get_dir_deg(deg, animations)

	# The player may have a state animation from before, which would be
	# resumed, so we immediately force the correct idle animation
	if animation_sprite.animation != animations.idles[last_dir][0]:
		animation_sprite.play(animations.idles[last_dir][0])
	pose_scale = animations.idles[last_dir][1]
	Movable.update_terrain()


func anim_finished():
	pass

func get_camera_pos():
	if camera_position_node and get_node(camera_position_node):
		return get_node(camera_position_node).global_position
	return global_position

func get_animations_list() -> PoolStringArray:
	return animation_sprite.get_sprite_frames().get_animation_names()

func start_talking():
	if animation_sprite.is_playing():
		animation_sprite.stop()
	animation_sprite.play(animations.speaks[last_dir][0])

func stop_talking():
	if animation_sprite.is_playing():
		animation_sprite.stop()
	animation_sprite.play(animations.idles[last_dir][0])


func teleport(target, angle : Object = null) -> void:
	Movable.teleport(target, angle)


func walk_to(pos : Vector2, p_walk_context = null):
	Movable.walk_to(pos, p_walk_context)
