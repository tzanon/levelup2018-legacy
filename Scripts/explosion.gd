extends Area2D

export var is_damaging = true
export var damage_amount = 0
export var impact_force = 0.0
export var debug_mode = false

#export var anim_name = ""
var animator

# only damage a given body once
var damaged_bodies = {}

func _ready():
	animator = get_node("AnimationPlayer")
	animator.connect("finished", self, "_despawn")
	
	#self.connect("body_enter", self, "_detect_entry")
	
	if debug_mode: print("explosion spawned")
	
	set_process(true)
	

func _process(delta):
	
	if is_damaging:
		var bodies = get_overlapping_bodies()
		#if debug_mode && bodies.size() > 0: print("bodies: ", bodies)
		for body in bodies:
			var body_name = body.get_name()
			if body.is_in_group("Damageable") && !damaged_bodies.has(body_name):
				if debug_mode: print("exploding ", body_name)
				# indicate damage done
				body.damage(damage_amount)
				damaged_bodies[body_name] = ""
				
				if body.get_type() == "RigidBody2D":
					# TODO: apply force
					#if debug_mode: print("pushing ", body_name)
					pass
	

func _detect_entry(body):
	if debug_mode: print("expl hit ", body)
	

func _despawn():
	if debug_mode: print("explosion despawned, has damaged ", damaged_bodies)
	self.queue_free()
