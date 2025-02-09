extends State

func state_enter(host, prev_state):
	pass

func state_physics_process(host, delta):
	if host.is_pushing:
		for player in host.players_to_push:
			var p = player as PlayerPhysics
			var speed : Vector2 = Vector2.ZERO
			var calc = (host.global_position.distance_to(p.global_position)-450)/300
			if host.target_h:
				if sign(p.speed.x) == -sign(host.character.scale.x):
					speed.x = calc * (150 + abs(p.speed.x)) * sign(p.speed.x)
				else:
					speed.x = calc * 150 * -sign(host.character.scale.x)
				speed = p.move_and_slide_preset(speed)
			else:
				if p.speed.y > 0:
					p.speed.y += calc * (100 + abs(p.speed.y))
				else:
					p.speed.y = calc * (100)
			
func state_animation_process(host, delta, animator):
	var anim_name
	
	if !host.is_pushing:
		if host.target_h:
			anim_name = "RotateToH"
		else:
			anim_name = "RotateToV"
	else:
		if host.target_h:
			anim_name = "FanH"
			host.up_blow.emitting = false
			host.side_blow.emitting = true
		else:
			anim_name = "FanV"
			host.up_blow.emitting = true
			host.side_blow.emitting = false
	
	animator.animate(anim_name)

func state_animation_finished(host, anim_name: String):
	if "Rotate" in anim_name and host.target_sighted:
		host.fan.play()
		host.is_pushing = true
		yield(host.get_tree().create_timer(5.0), "timeout")
		(host.fan as AudioStreamPlayer2D).stop()
		host.is_pushing = false
		host.target_sighted = false
		set_state_animation_processing(false)
		host.get_tree().create_timer(5.0).connect("timeout", host, "check_for_target")
		finish("Wait")
		set_state_animation_processing(true)

func state_exit(host, next_state):
	host.up_blow.emitting = false
	host.side_blow.emitting = false
