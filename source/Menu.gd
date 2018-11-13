extends Control

var mine_texture = ImageTexture.new()
var delta_texture = ImageTexture.new()

func _ready():
	switch_locale()
	resize()
	add_to_group("translations")
	add_to_group("resizable")

func _process(delta):
	var time_calc = 0
	time_calc = int(global.running_time / 10)
	var cs = time_calc % 100
	time_calc -= cs
	time_calc /= 100
	var s = time_calc % 60
	time_calc -= s
	time_calc /= 60
	var m = time_calc % 60
	time_calc -= m
	time_calc /= 60
	$Line2/Timer.text = str("%03d" % time_calc)+":"+str("%02d" % m)+":"+str("%02d" % s)+"."+str("%02d" % cs)

func switch_locale():
	$Line1/D0Value.hint_tooltip = TranslationServer.translate("SIZE1_TOOLTIP")
	$Line1/D0CheckBox.hint_tooltip = TranslationServer.translate("SPHERE1_TOOLTIP")
	$Line1/D1Value.hint_tooltip = TranslationServer.translate("SIZE2_TOOLTIP")
	$Line1/D1CheckBox.hint_tooltip = TranslationServer.translate("SPHERE2_TOOLTIP")
	$Line1/D2Value.hint_tooltip = TranslationServer.translate("SIZE3_TOOLTIP")
	$Line1/D2CheckBox.hint_tooltip = TranslationServer.translate("SPHERE3_TOOLTIP")
	$Line1/D3Value.hint_tooltip = TranslationServer.translate("SIZE4_TOOLTIP")
	$Line1/D3CheckBox.hint_tooltip = TranslationServer.translate("SPHERE4_TOOLTIP")
	$Line2/Start.text = TranslationServer.translate("START")
	$Line2/Start.hint_tooltip = TranslationServer.translate("START_TOOLTIP")
	$Line2/GetStarted.hint_tooltip = TranslationServer.translate("NICE_TOOLTIP")
	$Line2/Timer.hint_tooltip = TranslationServer.translate("TIME_TOOLTIP")
	if global.paused:
		$Line2/Pause.text = TranslationServer.translate("RESUME")
		$Line2/Pause.hint_tooltip = TranslationServer.translate("RESUME_TOOLTIP")
	else:
		$Line2/Pause.text = TranslationServer.translate("PAUSE")
		$Line2/Pause.hint_tooltip = TranslationServer.translate("PAUSE_TOOLTIP")
	$Line2/Remaining.hint_tooltip = TranslationServer.translate("REMAINING_TOOLTIP")
	$Line2/Settings.text = TranslationServer.translate("SETTINGS")
	$Line2/Settings.hint_tooltip = TranslationServer.translate("SETTINGS_TOOLTIP")
	$Line2/CheckBox.hint_tooltip = TranslationServer.translate("DELTA_TOOLTIP")

func resize():
	var L2y = 0
	$Line1/D0Value.get_font("font").size = 11 * global.scale
	$Line1/D0Value.rect_size = Vector2($Line2/Remaining.get_font("font").get_string_size("9999").x, 0)
	L2y = max(L2y, $Line1/D0Value.rect_size.y)
	$Line1/D0Value.text = $Line1/D0Value.text
	$Line1/D1Value.get_font("font").size = 11 * global.scale
	$Line1/D1Value.rect_size = Vector2($Line2/Remaining.get_font("font").get_string_size("9999").x, 0)
	L2y = max(L2y, $Line1/D1Value.rect_size.y)
	$Line1/D1Value.text = $Line1/D1Value.text
	$Line1/D2Value.get_font("font").size = 11 * global.scale
	$Line1/D2Value.rect_size = Vector2($Line2/Remaining.get_font("font").get_string_size("9999").x, 0)
	L2y = max(L2y, $Line1/D2Value.rect_size.y)
	$Line1/D2Value.text = $Line1/D2Value.text
	$Line1/D3Value.get_font("font").size = 11 * global.scale
	$Line1/D3Value.rect_size = Vector2($Line2/Remaining.get_font("font").get_string_size("9999").x, 0)
	L2y = max(L2y, $Line1/D3Value.rect_size.y)
	$Line1/Value.text = $Line1/Value.text
	$Line1/Value.get_font("font").size = 11 * global.scale
	$Line1/Value.rect_size = Vector2($Line2/Remaining.get_font("font").get_string_size("999999").x, 0)
	L2y = max(L2y, $Line1/D3Value.rect_size.y)
	$Line1/D3Value.text = $Line1/D3Value.text
	$Line1/D0Value.rect_position.x = $Line1/D0.position.x + $Line1/D0.texture.get_size().x
	$Line1/D0CheckBox.rect_position.x = $Line1/D0Value.rect_position.x + $Line1/D0Value.rect_size.x
	$Line1/D0Sprite.position.x = $Line1/D0Value.rect_position.x + $Line1/D0Value.rect_size.x
	
	$Line1/D1.position.x = $Line1/D0Sprite.position.x + $Line1/D0Sprite.texture.get_size().x + 3 * global.margin * global.scale
	$Line1/D1Value.rect_position.x = $Line1/D1.position.x + $Line1/D1.texture.get_size().x
	$Line1/D1CheckBox.rect_position.x = $Line1/D1Value.rect_position.x + $Line1/D1Value.rect_size.x
	$Line1/D1Sprite.position.x = $Line1/D1Value.rect_position.x + $Line1/D1Value.rect_size.x
	
	$Line1/D2.position.x = $Line1/D1Sprite.position.x + $Line1/D1Sprite.texture.get_size().x + 3 * global.margin * global.scale
	$Line1/D2Value.rect_position.x = $Line1/D2.position.x + $Line1/D2.texture.get_size().x
	$Line1/D2CheckBox.rect_position.x = $Line1/D2Value.rect_position.x + $Line1/D2Value.rect_size.x
	$Line1/D2Sprite.position.x = $Line1/D2Value.rect_position.x + $Line1/D2Value.rect_size.x
	
	$Line1/D3.position.x = $Line1/D2Sprite.position.x + $Line1/D2Sprite.texture.get_size().x + 3 * global.margin * global.scale
	$Line1/D3Value.rect_position.x = $Line1/D3.position.x + $Line1/D3.texture.get_size().x
	$Line1/D3CheckBox.rect_position.x = $Line1/D3Value.rect_position.x + $Line1/D3Value.rect_size.x
	$Line1/D3Sprite.position.x = $Line1/D3Value.rect_position.x + $Line1/D3Value.rect_size.x
	
	$Line1.rect_size.y = $Line1/Value.rect_position.y + L2y
	
	var mine_scale = $Line1.rect_size.y / global.mine_image.get_size().y
	mine_texture.create_from_image(global.mine_image)
	mine_texture.set_size_override(global.mine_image.get_size() * mine_scale)
	$Line1/Mine.texture = mine_texture
	$Line1/Mine.position.x = $Line1/D3Sprite.position.x + $Line1/D3Sprite.texture.get_size().x + 3 * global.margin * global.scale
	$Line1/Value.rect_position.x = $Line1/Mine.position.x + $Line1/Mine.texture.get_size().x * $Line1/Mine.scale.x
	
	$Line1.rect_size.x = $Line1/Value.rect_position.x + $Line1/Value.rect_size.x
	
	
	
	$Line2/Start.get_font("font").size = 12 * global.scale
	$Line2/Start.rect_size = Vector2(0, 0)
	$Line2.rect_size.y = max(0, $Line2/Start.rect_size.y)
	
	$Line2/GetStarted.disabled = global.running || global.finished
	$Line2/GetStarted.rect_position.x = $Line2/Start.rect_position.x + $Line2/Start.rect_size.x + 3 * global.margin * global.scale
	$Line2/GetStarted.get_font("font").size = 12 * global.scale
	$Line2/GetStarted.rect_size = Vector2(0, 0)
	$Line2.rect_size.y = max($Line2.rect_size.y, $Line2/GetStarted.rect_size.y)
	
	$Line2/Timer.rect_position.x = $Line2/GetStarted.rect_position.x + $Line2/GetStarted.rect_size.x + 3 * global.margin * global.scale
	$Line2/Timer.get_font("font").size = 11 * global.scale
	$Line2/Timer.rect_size = Vector2($Line2/Timer.get_font("font").get_string_size("000:00:00:0000").x, 0)
	$Line2.rect_size.y = max($Line2.rect_size.y, $Line2/Timer.rect_size.y)
	
	$Line2/Pause.rect_position.x = $Line2/Timer.rect_position.x + $Line2/Timer.rect_size.x + 3 * global.margin * global.scale
	$Line2/Pause.get_font("font").size = 12 * global.scale
	var pause_size_x
	$Line2/Pause.text = TranslationServer.translate("PAUSE")
	$Line2/Pause.rect_size = Vector2(0, 0)
	pause_size_x = $Line2/Pause.rect_size.x
	$Line2/Pause.text = TranslationServer.translate("RESUME")
	$Line2/Pause.rect_size = Vector2(0, 0)
	pause_size_x = max(pause_size_x, $Line2/Pause.rect_size.x)
	$Line2/Pause.rect_size.x = pause_size_x
	$Line2.rect_size.y = max($Line2.rect_size.y, $Line2/Pause.rect_size.y)
	if global.paused:
		$Line2/Pause.text = TranslationServer.translate("RESUME")
	else:
		$Line2/Pause.text = TranslationServer.translate("PAUSE")
	
	$Line2/Remaining.rect_position.x = $Line2/Pause.rect_position.x + $Line2/Pause.rect_size.x + 3 * global.margin * global.scale
	$Line2/Remaining.get_font("font").size = 11 * global.scale
	$Line2/Remaining.rect_size = Vector2($Line2/Remaining.get_font("font").get_string_size(str(global.mines) + "0").x, 0)
	$Line2.rect_size.y = max($Line2.rect_size.y, $Line2/Remaining.rect_size.y)
	
	$Line2/Settings.rect_position.x = $Line2/Remaining.rect_position.x + $Line2/Remaining.rect_size.x + 3 * global.margin * global.scale
	$Line2/Settings.get_font("font").size = 12 * global.scale
	$Line2/Settings.rect_size = Vector2(0, 0)
	$Line2.rect_size.y = max($Line2.rect_size.y, $Line2/Settings.rect_size.y)
	
	$Line2/Start.rect_size.y = $Line2.rect_size.y
	$Line2/GetStarted.rect_size.y = $Line2.rect_size.y
	$Line2/Timer.rect_size.y = $Line2.rect_size.y
	$Line2/Pause.rect_size.y = $Line2.rect_size.y
	$Line2/Remaining.rect_size.y = $Line2.rect_size.y
	$Line2/Settings.rect_size.y = $Line2.rect_size.y
	
	var delta_scale = $Line2.rect_size.y / global.delta_image.get_size().y
	delta_texture.create_from_image(global.delta_image)
	delta_texture.set_size_override(global.delta_image.get_size() * delta_scale)
	$Line2/Delta.texture = delta_texture
	$Line2/Delta.position.x = $Line2/Settings.rect_position.x + $Line2/Settings.rect_size.x + 3 * global.margin * global.scale
	var checkbox_scale = $Line2.rect_size.y / 24
	$Line2/CheckBox.rect_scale = Vector2(checkbox_scale, checkbox_scale)
	$Line2/CheckBox.rect_position.x = $Line2/Delta.position.x + $Line2/Delta.texture.get_size().x
	
	$Line2.rect_size.x = $Line2/CheckBox.rect_position.x + $Line2/CheckBox.rect_size.x
	
	rect_size.x = max($Line1.rect_size.x, $Line2.rect_size.x)
	$Line1.rect_position.x = (rect_size.x - $Line1.rect_size.x) / 2
	$Line2.rect_position.x = (rect_size.x - $Line2.rect_size.x) / 2
	$Line1.rect_position.y = 0
	$Line2.rect_position.y = $Line1.rect_position.y + $Line1.rect_size.y + global.margin * global.scale
	
	rect_size.y = $Line2.rect_position.y + $Line2.rect_size.y
	global.reposition()

func get_settigs():
	global.dimensions = [[int($Line1/D0Value.text), $Line1/D0CheckBox.pressed],
		[int($Line1/D1Value.text), $Line1/D1CheckBox.pressed],
		[int($Line1/D2Value.text), $Line1/D2CheckBox.pressed],
		[int($Line1/D3Value.text), $Line1/D3CheckBox.pressed]]
	global.mines = int($Line1/Value.text)
	global.delta = int($Line2/CheckBox.pressed)
	global.sanitize_settings()
	set_settigs()

func set_settigs():
	$Line1/D0Value.text = str(global.dimensions[0][0])
	$Line1/D0CheckBox.pressed = global.dimensions[0][1]
	$Line1/D1Value.text = str(global.dimensions[1][0])
	$Line1/D1CheckBox.pressed = global.dimensions[1][1]
	$Line1/D2Value.text = str(global.dimensions[2][0])
	$Line1/D2CheckBox.pressed = global.dimensions[2][1]
	$Line1/D3Value.text = str(global.dimensions[3][0])
	$Line1/D3CheckBox.pressed = global.dimensions[3][1]
	$Line1/Value.text = str(global.mines)
	$Line2/CheckBox.pressed = global.delta

func _on_CheckBox_toggled(button_pressed):
	global.delta = int($Line2/CheckBox.pressed)
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					global.blocks[a][b][c][d].redraw()


func _on_Start_pressed():
	if ! global.paused:
		_on_Pause_pressed()
	global.switch_input_state("none", global.position)
	global.newgame_menu.popup_centered()


func _on_GetStarted_pressed():
	if ! global.running && ! global.finished:
		var found = false
		global.switch_input_state("none", global.position)
		for a in range(global.blocks.size()):
			for b in range(global.blocks[0].size()):
				for c in range(global.blocks[0][0].size()):
					for d in range(global.blocks[0][0][0].size()):
						if ! global.blocks[a][b][c][d].mine && global.blocks[a][b][c][d].number == 0 && ! found:
							found = true
							global.blocks[a][b][c][d].clicked()
		if global.remaining == 0:
			global.win()
		if ! found:
			global.sorry_menu.popup_centered()


func _on_Pause_pressed():
	if global.running:
		global.paused = ! global.paused
		if global.paused:
			global.switch_input_state("none", global.position)
			global.calc_running_time()
			global.time_offset = global.running_time
		else:
			global.starting_time = OS.get_ticks_msec()
			$Line2/Pause.text = TranslationServer.translate("PAUSE")
			$Line2/Pause.hint_tooltip = TranslationServer.translate("PAUSE_TOOLTIP")
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					global.blocks[a][b][c][d].redraw()
	if global.paused:
		$Line2/Pause.text = TranslationServer.translate("RESUME")
		$Line2/Pause.hint_tooltip = TranslationServer.translate("RESUME_TOOLTIP")
	else:
		$Line2/Pause.text = TranslationServer.translate("PAUSE")
		$Line2/Pause.hint_tooltip = TranslationServer.translate("PAUSE_TOOLTIP")


func _on_Settings_pressed():
	if ! global.paused:
		_on_Pause_pressed()
	global.switch_input_state("none", global.position)
	global.settings_menu.popup_centered()

func update_remaining():
	$Line2/Remaining.text = str(global.remaining_mines)