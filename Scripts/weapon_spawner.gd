extends Node2D

export var refresh_interval = 4
var refresh_timer

const weapon_scenes = [
	preload("res://Scenes/Weapons/world_orange_ph.tscn"),
	preload("res://Scenes/Weapons/world_blue_ph.tscn")
] #world weapon scenes to instantiate from


#TODO: exported enum and case statement to select spawn mode

var light_weapon_scenes = []
var power_weapon_scenes = [] #more powerful: spawned in harder places

export(Array) var spawn_position_sets
export(Array) var total_spawn_positions #array of vector2
export(Array) var light_spawn_positions
export(Array) var power_spawn_positions

export(Dictionary) var position_weapon_scenes
export(Dictionary) var position_possible_weapon_scenes

export var MIN_SPAWN = 0
export var MAX_SPAWN = 10

var arena_weapon_refs #array of all weapons currently in the arena

func _ready():
	print("starting")
	refresh_timer = get_node("RefreshTimer")
	refresh_timer.set_wait_time(refresh_interval)
	refresh_timer.set_one_shot(true)
	refresh_timer.start()
	
	arena_weapon_refs = []
	_spawn_static_random()
	
	set_process(true)

func _process(delta):
	if refresh_timer.get_time_left() <= 0:
		print("refreshing weapons!")
		_clear_weapons()
		_spawn_static_random()
		refresh_timer.start()


func _clear_weapons():
	for weapon_ref in arena_weapon_refs:
		if weapon_ref.get_ref():
			print("weapon is ", weapon_ref.get_ref())
			weapon_ref.get_ref().queue_free()
	
	arena_weapon_refs.clear()


# different ways to spawn weapons

# spawns the corresponding weapon at each position
func _spawn_static_fixed():
	for pos in position_weapon_scenes.keys():
		var weapon = _spawn_weapon_with_position(pos)
		arena_weapon_refs.append(weakref(weapon))

# spawns a random weapon at each position
func _spawn_static_random():
	for pos in total_spawn_positions:
		var weapon = _spawn_random_weapon(pos)
		arena_weapon_refs.append(weakref(weapon))

# randomly selects positions and spawns the corresponding weapon at each
func _spawn_select_fixed():
	var spawn_positions = select_spawn_positions()
	for pos in spawn_positions():
		var weapon = _spawn_weapon_with_position(pos)
		arena_weapon_refs.append(weakref(weapon))

# randomly selects positions and spawns a random weapon at each
func _spawn_select_random():
	var spawn_positions = select_spawn_positions()
	for pos in total_spawn_positions:
		var weapon = _spawn_random_weapon(pos)
		arena_weapon_refs.append(weakref(weapon))



# randomly choose n unique spawn positions
func _select_spawn_positions():
	var num_weapons = randi() % (MAX_SPAWN - MIN_SPAWN + 1) + MIN_SPAWN
	var spawn_positions = []
	var possible_positions = [] + total_spawn_positions
	for i in range(num_weapons):
		var j = random(0, possible_positions.size())
		spawn_positions.append(possible_positions[j])
		possible_positions.remove(j)
	return spawn_positions



# spawns a random weapon at the given position
func _spawn_random_weapon(pos):
	var i = randi() % (weapon_scenes.size())
	var weapon = weapon_scenes[i].instance()
	weapon.set_global_pos(pos)
	print("spawned weapon ", weapon)
	#get_parent().add_child(weapon)
	#get_tree().get_root().add_child(weapon)
	get_tree().get_root().call_deferred("add_child", weapon)
	return weapon


# spawns weapon at its matching position
func _spawn_weapon_with_position(pos):
	var weapon = position_weapon_scenes[pos].instance()
	weapon.set_pos(pos)
	get_tree().get_root().add_child(weapon)
	return weapon


