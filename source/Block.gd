extends Area2D

var _mine_texture = ImageTexture.new()
var _flag_texture = ImageTexture.new()
var _question_texture = ImageTexture.new()
var _background_start_color = Color(0.1, 0.1, 0.1)
var _background_end_color = Color(0.1, 0.1, 0.1)
var _background_color_progress = 1
var _highlight_start_color = Color(0, 0, 0)
var _highlight_end_color = Color(0, 0, 0)
var _highlight_color_progress = 1
var _color_step_size = 25
var _highlighted = false
var _lowlighted = false
var _delta_number = number
var _delta_zero = true
var coordinates = [-1, -1, -1, -1]
var mine = false
var state = "covered" # in {"covered", "uncovered", "flagged", "questioned"}
var number = 0
var neighbors = []
var recalc_neighbors = true

func _ready():
	$Number.add_font_override("font", $Number.get_font("font").duplicate())
	z_index = -1
	add_to_group("resizable")
	exited()
	resize()
	set_physics_process(false)
	set_process_input(false)

func _process(delta):
	set_process(false)
	redraw(delta)

func redraw(delta = 0):
		var _temp_changed = false
		_highlight_color_progress = clamp(_highlight_color_progress + _color_step_size * delta, 0, 1)
		var _target_highlight = Color(0, 0, 0)
		if _highlighted:
			_target_highlight = Color(0, 1, 1)
		if ! _target_highlight == _highlight_end_color:
			_highlight_start_color = $Border.modulate
			_highlight_end_color = _target_highlight
			_highlight_color_progress = clamp(_color_step_size * delta, 0, 1)
		if ! $Border.modulate == _highlight_end_color:
			$Border.modulate = _highlight_start_color + (_highlight_end_color - _highlight_start_color) * _highlight_color_progress
			_temp_changed = _temp_changed || ! $Border.modulate == _highlight_end_color
		if global.delta:
			$Number.text = str(_delta_number)
		else:
			$Number.text = str(number)
		if int($Number.text) < -9:
			$Number.get_font("font").size = 15 * global.scale
		else:
			$Number.get_font("font").size = 21 * global.scale
		$Number.rect_size = Vector2(0, 0)
		$Number.rect_position = $Border.rect_size / 2 - $Number.rect_size / 2
		_background_color_progress = clamp(_background_color_progress + _color_step_size * delta, 0, 1)
		var _target_background = Color(0.1, 0.1, 0.1)
		if global.paused && ! global.finished:
			$Number.visible = false
			$Sprite.visible = false
		else:
			if state == "covered":
				if global.finished:
					if mine:
						$Number.visible = false
						$Sprite.visible = true
						$Sprite.set_texture(_flag_texture)
						$Sprite.set_texture(_mine_texture)
						_target_background = Color(0.5, 0.5, 0.5)
					else:
						if int($Number.text) == 0 && _delta_zero:
							$Number.visible = false
						else:
							$Number.visible = true
						$Sprite.visible = false
						if int($Number.text) >= 0:
							_target_background = Color(0.5, 0.5 - int($Number.text) * 0.07, 0.5 - int($Number.text) * 0.07)
						else:
							_target_background = Color(0.5, 0, 0)
				else:
					$Number.visible = false
					$Sprite.visible = false
					if _lowlighted:
						_target_background = Color(0.2, 0.2, 0.2)
					else:
						_target_background = Color(0.6, 0.6, 0.6)
			elif state == "uncovered":
				if mine:
					$Number.visible = false
					$Sprite.visible = true
					$Sprite.set_texture(_flag_texture)
					$Sprite.set_texture(_mine_texture)
					_target_background = Color(1, 0, 0)
				else:
					if int($Number.text) == 0 && _delta_zero:
						$Number.visible = false
					else:
						$Number.visible = true
					$Sprite.visible = false
					if int($Number.text) >= 0:
						_target_background = Color(1, 1 - int($Number.text) * 0.07, 1 - int($Number.text) * 0.07)
					else:
						_target_background = Color(1, 0, 0)
			elif state == "flagged":
				$Number.visible = false
				$Sprite.visible = true
				$Sprite.set_texture(_mine_texture)
				$Sprite.set_texture(_flag_texture)
				if global.finished:
					if mine:
						_target_background = Color(0, 1, 0)
					else:
						_target_background = Color(1, 0, 0)
				else:
					_target_background = Color(1, 1, 1)
			elif state == "questioned":
				$Number.visible = false
				$Sprite.visible = true
				$Sprite.set_texture(_mine_texture)
				$Sprite.set_texture(_question_texture)
				if global.finished:
					if mine:
						_target_background = Color(0, 1, 0)
					else:
						_target_background = Color(1, 0, 0)
				else:
					_target_background = Color(1, 1, 1)
		if ! _target_background == _background_end_color:
			_background_start_color = $Background.modulate
			_background_end_color = _target_background
			_background_color_progress = clamp(_color_step_size * delta, 0, 1)
		if ! $Background.modulate == _background_end_color:
			$Background.modulate = _background_start_color + (_background_end_color - _background_start_color) * _background_color_progress
			_temp_changed = _temp_changed || ! $Background.modulate == _background_end_color
		if _temp_changed:
			set_process(true)

func resize():
	var block_size = int(30 * global.scale)
	var border_size = ceil(global.scale)
	var background_size = block_size - 2 * border_size
	var mine_scale = background_size / global.mine_image.get_size().y
	_mine_texture.create_from_image(global.mine_image)
	_flag_texture.create_from_image(global.flag_image)
	_question_texture.create_from_image(global.question_image)
	_mine_texture.set_size_override(global.mine_image.get_size() * mine_scale)
	_flag_texture.set_size_override(global.flag_image.get_size() * mine_scale)
	_question_texture.set_size_override(global.question_image.get_size() * mine_scale)
	$Border.rect_size = Vector2(block_size, block_size)
	$Background.rect_size = Vector2(background_size, background_size)
	$Background.rect_position = Vector2(border_size, border_size)
	$Number.get_font("font").size = 21 * global.scale
	$Sprite.position = Vector2(border_size, border_size)
	$Collision.shape.extents = $Border.rect_size / 2
	$Collision.position = $Border.rect_position + $Collision.shape.extents
	set_process(true)

func count():
	if recalc_neighbors:
		get_neighbors()
	for i in neighbors:
		if global.blocks[i[0]][i[1]][i[2]][i[3]].mine:
			number = number + 1
	_delta_number = number
	set_process(true)

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

func entered():
	if recalc_neighbors:
		get_neighbors()
	set_lights({highlight = true})
	for i in neighbors:
		global.blocks[i[0]][i[1]][i[2]][i[3]].set_lights({highlight = true})

func exited():
	if recalc_neighbors:
		get_neighbors()
	set_lights({highlight = false, lowlight = false})
	for i in neighbors:
		global.blocks[i[0]][i[1]][i[2]][i[3]].set_lights({highlight = false, lowlight = false})

func clicked():
	var _temp_changed = false
	if recalc_neighbors:
		get_neighbors()
	if state == "covered" || state == "questioned":
		state = "uncovered"
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].update_delta_zero()
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
		_temp_changed = true
	if _temp_changed:
		set_process(true)

func uncover_neighbors():
	if recalc_neighbors:
		get_neighbors()
	if state == "uncovered" && _delta_number == 0:
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].clicked()

func flagged():
	var _temp_changed = false
	if recalc_neighbors:
		get_neighbors()
	if state == "covered" || state == "questioned":
		state = "flagged"
		global.remaining_mines = global.remaining_mines - 1
		global.menu.update_remaining()
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].change_delta(-1)
		if global.save_on_exit:
			global.save_game()
		_temp_changed = true
	elif state == "flagged":
		state = "covered"
		global.remaining_mines = global.remaining_mines + 1
		global.menu.update_remaining()
		for i in neighbors:
			global.blocks[i[0]][i[1]][i[2]][i[3]].change_delta(1)
		if global.save_on_exit:
			global.save_game()
		_temp_changed = true
	if _temp_changed:
		set_process(true)

func questioned():
	var _temp_changed = false
	if recalc_neighbors:
		get_neighbors()
	if state == "covered":
		state = "questioned"
		if global.save_on_exit:
			global.save_game()
		_temp_changed = true
	elif state == "questioned":
		state = "covered"
		if global.save_on_exit:
			global.save_game()
		_temp_changed = true
	if _temp_changed:
		set_process(true)

func set_lights(options):
	var _temp_changed = false
	if options.has("highlight"):
		if ! options.highlight == _highlighted:
			_temp_changed = true
			_highlighted = options.highlight
	if options.has("lowlight"):
		if ! options.lowlight == _lowlighted:
			_temp_changed = true
			_lowlighted = options.lowlight
	if _temp_changed:
		set_process(true)

func change_delta(how):
	var _temp_changed = false
	if how == 1:
		_delta_number = _delta_number + 1
		_temp_changed = true
	elif how == -1:
		_delta_number = _delta_number - 1
		_temp_changed = true
	update_delta_zero()
	if _temp_changed:
		set_process(true)

func update_delta_zero():
	if recalc_neighbors:
		get_neighbors()
	var _local_delta_zero
	_local_delta_zero = true
	if _delta_number == 0:
		for i in neighbors:
			_local_delta_zero = _local_delta_zero && ! global.blocks[i[0]][i[1]][i[2]][i[3]].state == "covered"
	if ! _local_delta_zero == _delta_zero:
		_delta_zero = _local_delta_zero
		set_process(true)