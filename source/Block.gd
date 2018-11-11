extends Node2D

var mine_texture = ImageTexture.new()
var flag_texture = ImageTexture.new()
var coordinates = [-1, -1, -1, -1]
var mine = false
var state = "covered" # in {"covered", "uncovered", "flagged"}
var highlighted = false
var lowlighted = false
var number = 0
var delta_number = number
var style_border = StyleBoxFlat.new()
var style_background = StyleBoxFlat.new()
var neighbors = []
var inside = false
var recalc_neighbors = true

func _ready():
	$Number.add_font_override("font", $Number.get_font("font").duplicate())
	z_index = -1
	add_to_group("resizable")
	exited()
	resize()

func redraw():
	if highlighted:
		style_border.set_bg_color(Color(0, 1, 1))
	else:
		style_border.set_bg_color(Color(0, 0, 0))
	if global.delta:
		$Number.text = str(delta_number)
	else:
		$Number.text = str(number)
	if int($Number.text) < -9:
		$Number.get_font("font").size = 15 * global.scale
	else:
		$Number.get_font("font").size = 21 * global.scale
	$Number.rect_size = Vector2(0, 0)
	$Number.rect_position = $Border.rect_size / 2 - $Number.rect_size / 2
	if global.paused && ! global.finished:
		$Number.visible = false
		$Sprite.visible = false
		style_background.set_bg_color(Color(0.1, 0.1, 0.1))
	else:
		if state == "covered":
			if global.finished:
				if mine:
					$Number.visible = false
					$Sprite.visible = true
					$Sprite.set_texture(flag_texture)
					$Sprite.set_texture(mine_texture)
					style_background.set_bg_color(Color(0.5, 0.5, 0.5))
				else:
					$Number.visible = true
					$Sprite.visible = false
					if int($Number.text) >= 0:
						style_background.set_bg_color(Color(0.5, 0.5 - int($Number.text) * 0.07, 0.5 - int($Number.text) * 0.07))
					else:
						style_background.set_bg_color(Color(0.5, 0, 0))
			else:
				$Number.visible = false
				$Sprite.visible = false
				if lowlighted:
					style_background.set_bg_color(Color(0.2, 0.2, 0.2))
				else:
					style_background.set_bg_color(Color(0.6, 0.6, 0.6))
		elif state == "uncovered":
			if mine:
				$Number.visible = false
				$Sprite.visible = true
				$Sprite.set_texture(flag_texture)
				$Sprite.set_texture(mine_texture)
				style_background.set_bg_color(Color(1, 0, 0))
			else:
				$Number.visible = true
				$Sprite.visible = false
				if int($Number.text) >= 0:
					style_background.set_bg_color(Color(1, 1 - int($Number.text) * 0.07, 1 - int($Number.text) * 0.07))
				else:
					style_background.set_bg_color(Color(1, 0, 0))
		elif state == "flagged":
			$Number.visible = false
			$Sprite.visible = true
			$Sprite.set_texture(mine_texture)
			$Sprite.set_texture(flag_texture)
			if global.finished:
				if mine:
					style_background.set_bg_color(Color(0, 1, 0))
				else:
					style_background.set_bg_color(Color(1, 0, 0))
			else:
				style_background.set_bg_color(Color(1, 1, 1))
	$Border.set('custom_styles/panel', style_border)
	$Background.set('custom_styles/panel', style_background)

func resize():
	var block_size = int(30 * global.scale)
	var border_size = ceil(global.scale)
	var background_size = block_size - 2 * border_size
	var mine_scale = background_size / global.mine_image.get_size().y
	mine_texture.create_from_image(global.mine_image)
	flag_texture.create_from_image(global.flag_image)
	mine_texture.set_size_override(global.mine_image.get_size() * mine_scale)
	flag_texture.set_size_override(global.flag_image.get_size() * mine_scale)
	$Border.rect_size = Vector2(block_size, block_size)
	$Background.rect_size = Vector2(background_size, background_size)
	$Background.rect_position = Vector2(border_size, border_size)
	$Number.get_font("font").size = 21 * global.scale
	$Sprite.position = Vector2(border_size, border_size)
	redraw()

func count():
	if recalc_neighbors:
		get_neighbors()
	for i in neighbors:
		if global.blocks[i[0]][i[1]][i[2]][i[3]].mine:
			number = number + 1
	delta_number = number
	redraw()

func get_neighbors():
	neighbors = []
	var temp_list = []
	var maximum = [global.dimensions[0][0] - 1, global.dimensions[1][0] - 1, global.dimensions[2][0] - 1, global.dimensions[3][0] - 1]
	var minimum = [0, 0, 0, 0]
	for i in range(4):
		if bool(global.dimensions[i][1]):
			maximum[i] = coordinates[i] + 1
			minimum[i] = coordinates[i] - 1
		else:
			maximum[i] = min(coordinates[i] + 1, maximum[i])
			minimum[i] = max(coordinates[i] - 1, minimum[i])
	for d in range(minimum[3], maximum[3] + 1):
		for c in range(minimum[2], maximum[2] + 1):
			for b in range(minimum[1], maximum[1] + 1):
				for a in range(minimum[0], maximum[0] + 1):
					if [int(fposmod(a, global.dimensions[0][0])), int(fposmod(b, global.dimensions[1][0])), int(fposmod(c, global.dimensions[2][0])),  int(fposmod(d, global.dimensions[3][0]))] != coordinates:
						temp_list.append([int(fposmod(a, global.dimensions[0][0])), int(fposmod(b, global.dimensions[1][0])), int(fposmod(c, global.dimensions[2][0])),  int(fposmod(d, global.dimensions[3][0]))])
	for i in temp_list:
		if neighbors.find(i) == -1:
			neighbors.append(i)
	recalc_neighbors = false

func _physics_process(delta):
	if 0 <= $Border.get_local_mouse_position().x && 0 <= $Border.get_local_mouse_position().y && $Border.get_local_mouse_position().x <= $Border.rect_size.x && $Border.get_local_mouse_position().y <= $Border.rect_size.y && global.inside:
		if ! inside && global.position.find(-1) > -1:
			entered()
	else:
		if inside:
			exited()

func entered():
	inside = true
	if recalc_neighbors:
		get_neighbors()
	global.position = coordinates
	global.switch_input_state(global.input_state, coordinates)

func exited():
	inside = false
	if recalc_neighbors:
		get_neighbors()
	highlight(false)
	lowlight(false)
	for i in neighbors:
		global.blocks[i[0]][i[1]][i[2]][i[3]].highlight(false)
		global.blocks[i[0]][i[1]][i[2]][i[3]].lowlight(false)
	global.position = [-1, -1, -1, -1]

func clicked():
	if recalc_neighbors:
		get_neighbors()
	if state == "covered":
		state = "uncovered"
		if ! global.running:
			global.set_running(true)
			global.starting_time = OS.get_ticks_msec()
		if mine:
			global.lost = true
		else:
			global.remaining = global.remaining - 1
			if $Number.text == "0":
				for i in neighbors:
					global.blocks[i[0]][i[1]][i[2]][i[3]].clicked()
		if global.save_on_exit:
			global.save_game()
		redraw()

func uncover_neighbors():
	if recalc_neighbors:
		get_neighbors()
	if state == "uncovered" && delta_number == 0:
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].clicked()

func flagged():
	if recalc_neighbors:
		get_neighbors()
	if state == "covered":
		state = "flagged"
		global.remaining_mines = global.remaining_mines - 1
		global.menu.update_remaining()
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].change_delta(-1)
		if global.save_on_exit:
			global.save_game()
		redraw()
	elif state == "flagged":
		state = "covered"
		global.remaining_mines = global.remaining_mines + 1
		global.menu.update_remaining()
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].change_delta(1)
		if global.save_on_exit:
			global.save_game()
		redraw()

func lowlight(what):
	if ! what == lowlighted:
		lowlighted = what
		redraw()

func highlight(what):
	if ! what == highlighted:
		highlighted = what
		redraw()

func change_delta(how):
	if how == 1:
		delta_number = delta_number + 1
		redraw()
	elif how == -1:
		delta_number = delta_number - 1
		redraw()