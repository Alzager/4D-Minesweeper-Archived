extends Node

var _position = [-1, -1, -1, -1]
var _state = "none" # in {"none", "lowlight this", "lowlight neighbors", "drag"}
var _drag_start = []

func _input(event):
	var _inside = ! global.settings_menu.is_visible_in_tree() && ! global.newgame_menu.is_visible_in_tree() && ! global.win_menu.is_visible_in_tree() && ! global.lose_menu.is_visible_in_tree() && ! global.message_menu.is_visible_in_tree()
	if _inside:
		var space_state = get_tree().get_root().get_world_2d().direct_space_state
		var colliders = space_state.intersect_point(get_viewport().get_mouse_position(), 1, [], 2)
		_inside = colliders.size() > 0
		if _inside:
			colliders = space_state.intersect_point(get_viewport().get_mouse_position(), 1, [], 1)
			if colliders.size() > 0:
				var block = space_state.intersect_point(get_viewport().get_mouse_position(), 1, [], 1)[0].collider
				if ! block.coordinates == input._position:
					if input._position.find(-1) == -1:
						global.blocks[input._position[0]][input._position[1]][input._position[2]][input._position[3]].exited()
					input._position = block.coordinates
					block.entered()
					input._switch_state(input._state, block.coordinates)
				if event is InputEventMouseButton && ! global.finished && ! global.paused:
					if input._state == "none" && event.pressed:
						if event.button_index == 1:
							input._switch_state("lowlight this", block.coordinates)
						elif event.button_index == 2:
							input._switch_state("none", block.coordinates)
							block.flagged()
						elif event.button_index == 3:
							input._drag_start = block.coordinates
							input._switch_state("drag", block.coordinates)
					elif input._state == "lowlight this":
						if event.button_index == 1 && ! event.pressed:
							input._switch_state("none", block.coordinates)
							block.clicked()
						elif event.button_index == 2 && event.pressed:
							input._switch_state("lowlight neighbors", block.coordinates)
					elif input._state == "lowlight neighbors":
						if event.button_index == 1 && ! event.pressed:
							input._switch_state("none", block.coordinates)
							block.uncover_neighbors()
						elif event.button_index == 2 && ! event.pressed:
							input._switch_state("lowlight this", block.coordinates)
					elif input._state == "drag" && event.button_index == 3 && ! event.pressed:
						input._position = [-1, -1, -1, -1]
						input._switch_state("none", block.coordinates)
					if global.lost:
						global.lose()
					elif global.remaining == 0:
						global.win()
			else:
				if input._position.find(-1) == -1:
					global.blocks[input._position[0]][input._position[1]][input._position[2]][input._position[3]].exited()
					input._position = [-1, -1, -1, -1]
	if ! _inside:
		input._switch_state("none", input._position)
		if input._position.find(-1) == -1:
			global.blocks[input._position[0]][input._position[1]][input._position[2]][input._position[3]].exited()
			input._position = [-1, -1, -1, -1]
	if event is InputEventMouseButton && event.pressed && Input.is_key_pressed(OS.find_scancode_from_string("Control")):
		if event.button_index == 4:
			global.scale = global.scale + 0.1
			global.changed = true
		elif event.button_index == 5:
			global.scale = global.scale - 0.1
			global.changed = true
		if global.changed:
			global.scale = clamp(global.scale, 0.5, 4)

func _physics_process(delta):
	var _inside = ! global.settings_menu.is_visible_in_tree() && ! global.newgame_menu.is_visible_in_tree() && ! global.win_menu.is_visible_in_tree() && ! global.lose_menu.is_visible_in_tree() && ! global.message_menu.is_visible_in_tree()
	if _inside:
		var space_state = get_tree().get_root().get_world_2d().direct_space_state
		var colliders = space_state.intersect_point(get_viewport().get_mouse_position(), 1, [], 2)
		_inside = colliders.size() > 0
		if _inside:
			colliders = space_state.intersect_point(get_viewport().get_mouse_position(), 1, [], 1)
			if colliders.size() > 0:
				var block = space_state.intersect_point(get_viewport().get_mouse_position(), 1, [], 1)[0].collider
				if ! block.coordinates == input._position:
					if input._position.find(-1) == -1:
						global.blocks[input._position[0]][input._position[1]][input._position[2]][input._position[3]].exited()
					input._position = block.coordinates
					block.entered()
					input._switch_state(input._state, block.coordinates)
			else:
				if input._position.find(-1) == -1:
					global.blocks[input._position[0]][input._position[1]][input._position[2]][input._position[3]].exited()
					input._position = [-1, -1, -1, -1]
	if ! _inside:
		input._switch_state("none", input._position)
		if input._position.find(-1) == -1:
			global.blocks[input._position[0]][input._position[1]][input._position[2]][input._position[3]].exited()
			input._position = [-1, -1, -1, -1]

func _switch_state(to, where):
	if ! to == "drag":
		if to == "none":
			input._state = "none"
			if where.find(-1) == -1:
				global.blocks[where[0]][where[1]][where[2]][where[3]].set_lights({lowlight = false})
				for i in global.blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
					global.blocks[i[0]][i[1]][i[2]][i[3]].set_lights({lowlight = false})
		elif to == "lowlight this":
			input._state = "lowlight this"
			if where.find(-1) == -1:
				global.blocks[where[0]][where[1]][where[2]][where[3]].set_lights({lowlight = true})
				for i in global.blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
					global.blocks[i[0]][i[1]][i[2]][i[3]].set_lights({lowlight = false})
		elif to == "lowlight neighbors":
			input._state = "lowlight neighbors"
			if where.find(-1) == -1:
				global.blocks[where[0]][where[1]][where[2]][where[3]].set_lights({lowlight = true})
				for i in global.blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
					global.blocks[i[0]][i[1]][i[2]][i[3]].set_lights({lowlight = true})
	else:
		input._state = "drag"
		if where.find(-1) == -1:
			global.blocks[where[0]][where[1]][where[2]][where[3]].set_lights({highlight = false})
			for i in global.blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
				global.blocks[i[0]][i[1]][i[2]][i[3]].set_lights({highlight = false})
		if ! input._drag_start == where:
			global.shift(input._drag_start, where)