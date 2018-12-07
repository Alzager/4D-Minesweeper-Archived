extends Area2D

var _mine_texture = ImageTexture.new()
var _flag_texture = ImageTexture.new()
var _style_border = StyleBoxFlat.new()
var _style_background = StyleBoxFlat.new()
var _highlighted = false
var _lowlighted = false
var _delta_number = number
var _changed = false
var _color_step_size = 5
var coordinates = [-1, -1, -1, -1]
var mine = false
var state = "covered" # in {"covered", "uncovered", "flagged"}
var number = 0
var neighbors = []
var recalc_neighbors = true

func _ready():
	$Number.add_font_override("font", $Number.get_font("font").duplicate())
	z_index = -1
	add_to_group("resizable")
	exited()
	resize()

func _process(delta):
	if _changed:
		_changed = false
		var _temp_changed = false
		var _target_background = Color(0.1, 0.1, 0.1)
		if _highlighted && $Border.modulate.g < 1:
			$Border.modulate = Color(0, clamp($Border.modulate.g + _color_step_size * delta, 0, 1), clamp($Border.modulate.b + _color_step_size * delta, 0, 1))
			_temp_changed = _temp_changed || $Border.modulate.g < 1
		elif ! _highlighted && $Border.modulate.g > 0:
			$Border.modulate = Color(0, clamp($Border.modulate.g - _color_step_size * delta, 0, 1), clamp($Border.modulate.b - _color_step_size * delta, 0, 1))
			_temp_changed = _temp_changed || $Border.modulate.g > 0
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
		if $Background.modulate.r > _target_background.r:
			$Background.modulate.r = clamp($Background.modulate.r - _color_step_size * delta, _target_background.r, 1)
			_temp_changed = _temp_changed || ! $Background.modulate.r == _target_background.r
		elif $Background.modulate.r < _target_background.r:
			$Background.modulate.r = clamp($Background.modulate.r + _color_step_size * delta, 0, _target_background.r)
			_temp_changed = _temp_changed || ! $Background.modulate.r == _target_background.r
		if $Background.modulate.g > _target_background.g:
			$Background.modulate.g = clamp($Background.modulate.g - _color_step_size * delta, _target_background.g, 1)
			_temp_changed = _temp_changed || ! $Background.modulate.g == _target_background.g
		elif $Background.modulate.g < _target_background.g:
			$Background.modulate.g = clamp($Background.modulate.g + _color_step_size * delta, 0, _target_background.g)
			_temp_changed = _temp_changed || ! $Background.modulate.g == _target_background.g
		if $Background.modulate.b > _target_background.b:
			$Background.modulate.b = clamp($Background.modulate.b - _color_step_size * delta, _target_background.b, 1)
			_temp_changed = _temp_changed || ! $Background.modulate.b == _target_background.b
		elif $Background.modulate.b < _target_background.b:
			$Background.modulate.b = clamp($Background.modulate.b + _color_step_size * delta, 0, _target_background.b)
			_temp_changed = _temp_changed || ! $Background.modulate.b == _target_background.b
		_changed = _changed || _temp_changed

func resize():
	var block_size = int(30 * global.scale)
	var border_size = ceil(global.scale)
	var background_size = block_size - 2 * border_size
	var mine_scale = background_size / global.mine_image.get_size().y
	_mine_texture.create_from_image(global.mine_image)
	_flag_texture.create_from_image(global.flag_image)
	_mine_texture.set_size_override(global.mine_image.get_size() * mine_scale)
	_flag_texture.set_size_override(global.flag_image.get_size() * mine_scale)
	$Border.rect_size = Vector2(block_size, block_size)
	$Background.rect_size = Vector2(background_size, background_size)
	$Background.rect_position = Vector2(border_size, border_size)
	$Number.get_font("font").size = 21 * global.scale
	$Sprite.position = Vector2(border_size, border_size)
	$Collision.shape.extents = $Border.rect_size / 2
	$Collision.position = $Border.rect_position + $Collision.shape.extents
	_changed = true

func count():
	if recalc_neighbors:
		get_neighbors()
	for i in neighbors:
		if global.blocks[i[0]][i[1]][i[2]][i[3]].mine:
			number = number + 1
	_delta_number = number
	_changed = true

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
		_temp_changed = true
	_changed = _changed || _temp_changed

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
	if state == "covered":
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
	_changed = _changed || _temp_changed

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
	_changed = _changed || _temp_changed

func change_delta(how):
	var _temp_changed = false
	if how == 1:
		_delta_number = _delta_number + 1
		_temp_changed = true
	elif how == -1:
		_delta_number = _delta_number - 1
		_temp_changed = true
	_changed = _changed || _temp_changed