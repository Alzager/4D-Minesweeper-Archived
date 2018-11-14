extends Node

var inside = false
var delta = true
var dimensions = [[4, false], [4, false], [4, false], [4, false]]
var mines = 10
var blocks = []
var scale = 1.0 # in [0.5, 4]
var paused = false
var running = false
var finished = false
var block = preload("res://Block.tscn")
var board_object = load("res://Board.tscn")
var board
var menu = load("res://Menu.tscn").instance()
var margin = 5
var position = [-1, -1, -1, -1]
var remaining = 246
var remaining_mines = 10
var lost = false
var input_state = "none" # in {"none", "lowlight this", "lowlight neighbors", "drag"}
var board_height = 0
var started = false
var time_offset = 0
var running_time = 0
var starting_time = 0
var config = "user://config.cfg"
var minX = 600
var minY = 600
var save_on_exit = true
var locale = "en"
var settings = preload("res://Settings.tscn")
var settings_menu = settings.instance()
var newgame = preload("res://NewGame.tscn")
var newgame_menu = newgame.instance()
var lose = preload("res://Lose.tscn")
var lose_menu = lose.instance()
var win = preload("res://Win.tscn")
var win_menu = win.instance()
var sorry = preload("res://Sorry.tscn")
var sorry_menu = sorry.instance()
var successes_file_path = "user://successes"
var game_id = ""
var savefile = "user://save.sav"
var mine_image = Image.new()
var delta_image = Image.new()
var flag_image = Image.new()
var sphere_image = Image.new()
var down_image = Image.new()
var right_image = Image.new()
var super_down_image = Image.new()
var super_right_image = Image.new()
var exports = ProjectSettings.globalize_path("res://")
var drag_start = []
var resizing = false
var changed = false
var first_start = false

func switch_locale():
	TranslationServer.set_locale(locale)
	for node in get_tree().get_nodes_in_group("translations"):
		node.switch_locale()
	resize()

func resize():
	if ! resizing:
		resizing = true
		if OS.window_size.x < minX:
			OS.window_size.x = minX
		if OS.window_size.y < minY:
			OS.window_size.y = minY
		for node in get_tree().get_nodes_in_group("resizable"):
			node.resize()
		reposition()

func reposition():
	menu.rect_position.x = 0
	board.rect_position.x = (OS.window_size.x - board.rect_size.x) / 2
	menu.rect_position.y = max(0, (OS.window_size.y - menu.rect_size.y - board.rect_size.y - global.margin * global.scale) / 2)
	board.rect_position.y = global.menu.rect_position.y + global.menu.rect_size.y + global.margin * global.scale
	resizing = false

func set_running(to):
	running = to
	menu.get_node("Line2/GetStarted").disabled = running

func load_game():
	var mines_list = []
	var uncovered_list = []
	var flaged_list = []
	var loaddict = {}
	var savegame = File.new()
	savegame.open(savefile, File.READ)
	loaddict = parse_json(savegame.get_line())
	savegame.close()
	finished = bool(loaddict["ended"])
	if ! finished:
		dimensions = [[int(loaddict["size"][0]), bool(loaddict["sphere"][0])], [int(loaddict["size"][1]), bool(loaddict["sphere"][1])], [int(loaddict["size"][2]), bool(loaddict["sphere"][2])], [int(loaddict["size"][3]), bool(loaddict["sphere"][3])]]
		mines_list = loaddict["mines_list"]
		uncovered_list = loaddict["uncovered_list"]
		flaged_list = loaddict["flaged_list"]
		game_id = loaddict["game_id"]
		set_running(true)
		finished = false
		paused = false
		dimensions = [[int(loaddict["size"][0]), bool(loaddict["sphere"][0])], [int(loaddict["size"][1]), bool(loaddict["sphere"][1])], [int(loaddict["size"][2]), bool(loaddict["sphere"][2])], [int(loaddict["size"][3]), bool(loaddict["sphere"][3])]]
		mines = int(mines_list.size())
		sanitize_settings()
		menu.set_settigs()
		initialize_blocks()
		for i in mines_list:
			global.blocks[i[0]][i[1]][i[2]][i[3]].mine = true
		count()
		for i in uncovered_list:
			global.blocks[i[0]][i[1]][i[2]][i[3]].clicked()
		for i in flaged_list:
			global.blocks[i[0]][i[1]][i[2]][i[3]].flagged()
		menu._on_Pause_pressed()
		time_offset = loaddict["time"] * 1000
		running_time = loaddict["time"] * 1000
		global.save_game()
		board = board_object.instance()
		board.initialize()
		get_tree().get_root().call_deferred("add_child", board)

func save_game():
	var mines_list = []
	var uncovered_list = []
	var flaged_list = []
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					if global.blocks[a][b][c][d].mine:
						mines_list.append([a, b, c, d])
					if global.blocks[a][b][c][d].state == "uncovered":
						uncovered_list.append([a, b, c, d])
					if global.blocks[a][b][c][d].state == "flagged":
						flaged_list.append([a, b, c, d])
	var savegame = File.new()
	var savedict = {
	size=[dimensions[0][0], dimensions[1][0], dimensions[2][0], dimensions[3][0]],
	sphere=[int(dimensions[0][1]), int(dimensions[1][1]), int(dimensions[2][1]), int(dimensions[3][1])],
	time=running_time / 1000,
	mines_list=mines_list,
	uncovered_list=uncovered_list,
	flaged_list=flaged_list,
	ended=int(finished),
	game_id=game_id
	}
	if mines_list.size() > 0 && uncovered_list.size() > 0:
		savegame.open(savefile, File.WRITE)
		savegame.store_line(to_json(savedict))
		savegame.close()

func export_game(name):
	if ! name == "" && ! name == "successes" && ! name == "save.sav" && ! name == "config.cfg" && ! "/" in name && ! "\\" in name && ! ":" in name && ! "*" in name && ! "\"" in name && ! "?" in name && ! "<" in name && ! ">" in name && ! "|" in name:
		var successes_file = File.new()
		var successes = {}
		if successes_file.open(global.successes_file_path, File.READ) == OK:
			successes = parse_json(successes_file.get_line())
		successes_file.close()
		if successes.has(name):
			successes.erase(name)
			successes_file.open(successes_file_path, File.WRITE)
			successes_file.store_line(to_json(successes))
			successes_file.close()
		var mines_list = []
		for a in range(global.blocks.size()):
			for b in range(global.blocks[0].size()):
				for c in range(global.blocks[0][0].size()):
					for d in range(global.blocks[0][0][0].size()):
						if global.blocks[a][b][c][d].mine:
							mines_list.append([a, b, c, d])
		var export_game = File.new()
		var savedict = {
		size=[dimensions[0][0], dimensions[1][0], dimensions[2][0], dimensions[3][0]],
		sphere=[int(dimensions[0][1]), int(dimensions[1][1]), int(dimensions[2][1]), int(dimensions[3][1])],
		mines_list=mines_list
		}
		export_game.open("user://" + name, File.WRITE)
		export_game.store_line(to_json(savedict))
		export_game.close()
		game_id = name
		if ! lost && remaining == 0:
			add_win()
		settings_menu.update_imports()
		settings_menu._on_ExportLineEdit_text_changed()
		win_menu._on_ExportLineEdit_text_changed()

func add_win():
	var successes_file = File.new()
	var successes = {}
	if successes_file.open(global.successes_file_path, File.READ) == OK:
		successes = parse_json(successes_file.get_line())
	successes_file.close()
	var time = menu.get_node("Line2/Timer").text
	var timer = time
	time.erase(9, 1)
	time.erase(6, 1)
	time.erase(3, 1)
	if successes.has(game_id):
		var time_old = successes[game_id]
		time_old.erase(9, 1)
		time_old.erase(6, 1)
		time_old.erase(3, 1)
		if int(time) < int(time_old):
			successes[game_id] = timer
	else:
		successes[game_id] = timer
	successes_file.open(successes_file_path, File.WRITE)
	successes_file.store_line(to_json(successes))
	successes_file.close()

func import_game(path, name):
	clear_board()
	var mines_list = []
	var loaddict = {}
	var savegame = File.new()
	savegame.open(path, File.READ)
	loaddict = parse_json(savegame.get_line())
	savegame.close()
	set_running(false)
	finished = false
	paused = false
	menu._on_Pause_pressed()
	dimensions = [[int(loaddict["size"][0]), bool(loaddict["sphere"][0])], [int(loaddict["size"][1]), bool(loaddict["sphere"][1])], [int(loaddict["size"][2]), bool(loaddict["sphere"][2])], [int(loaddict["size"][3]), bool(loaddict["sphere"][3])]]
	mines_list = loaddict["mines_list"]
	mines = int(mines_list.size())
	sanitize_settings()
	menu.set_settigs()
	game_id = name
	initialize_blocks()
	for i in mines_list:
		global.blocks[i[0]][i[1]][i[2]][i[3]].mine = true
	count()
	board = board_object.instance()
	board.initialize()
	get_tree().get_root().call_deferred("add_child", board)

func _ready():
	delta_image = get_tree().get_root().get_node("Main").get_node("Delta").texture.get_data()
	flag_image = get_tree().get_root().get_node("Main").get_node("Flag").texture.get_data()
	mine_image = get_tree().get_root().get_node("Main").get_node("Mine").texture.get_data()
	sphere_image = get_tree().get_root().get_node("Main").get_node("Sphere").texture.get_data()
	down_image = get_tree().get_root().get_node("Main").get_node("Down").texture.get_data()
	right_image = get_tree().get_root().get_node("Main").get_node("Right").texture.get_data()
	super_down_image = get_tree().get_root().get_node("Main").get_node("SuperDown").texture.get_data()
	super_right_image = get_tree().get_root().get_node("Main").get_node("SuperRight").texture.get_data()
	read_config()
	if OS.get_name() == "OSX":
		exports = ProjectSettings.globalize_path("res://") + "../../../"
	get_tree().get_root().connect("size_changed", self, "resize")
	get_tree().get_root().call_deferred("add_child", menu)
	get_tree().get_root().call_deferred("add_child", settings_menu)
	get_tree().get_root().call_deferred("add_child", newgame_menu)
	get_tree().get_root().call_deferred("add_child", lose_menu)
	get_tree().get_root().call_deferred("add_child", win_menu)
	get_tree().get_root().call_deferred("add_child", sorry_menu)
	settings_menu.update_ui()
	var savegame = File.new()
	if savegame.file_exists(savefile) && save_on_exit:
		load_game()
	else:
		new_game()
	switch_locale()
	write_config()

func read_config():
	var configFile = ConfigFile.new()
	if configFile.load(config) == OK:
		if configFile.has_section("Config"):
			if configFile.has_section_key("Config", "size"):
				for i in range(4):
					dimensions[i][0] = configFile.get_value("Config", "size")[i]
			if configFile.has_section_key("Config", "sphere"):
				for i in range(4):
					dimensions[i][1] = bool(configFile.get_value("Config", "sphere")[i])
			if configFile.has_section_key("Config", "mines"):
				mines = configFile.get_value("Config", "mines")
			if configFile.has_section_key("Config", "o"):
				margin = configFile.get_value("Config", "o")
			if configFile.has_section_key("Config", "scale_factor"):
				scale = configFile.get_value("Config", "scale_factor")
			if configFile.has_section_key("Config", "delta_box"):
				delta = bool(configFile.get_value("Config", "delta_box"))
			if configFile.has_section_key("Config", "minX"):
				minX = configFile.get_value("Config", "minX")
			if configFile.has_section_key("Config", "minY"):
				minY = configFile.get_value("Config", "minY")
			if configFile.has_section_key("Config", "save_on_exit"):
				save_on_exit = bool(configFile.get_value("Config", "save_on_exit"))
			if configFile.has_section_key("Config", "locale"):
				locale = configFile.get_value("Config", "locale")
	else:
		first_start = true
	menu.set_settigs()

func write_config():
	var configFile = ConfigFile.new()
	var save_size = [int(menu.get_node("Line1/D0Value").text), int(menu.get_node("Line1/D1Value").text), int(menu.get_node("Line1/D2Value").text), int(menu.get_node("Line1/D3Value").text)]
	var save_sphere = [int(menu.get_node("Line1/D0CheckBox").pressed), int(menu.get_node("Line1/D1CheckBox").pressed), int(menu.get_node("Line1/D2CheckBox").pressed), int(menu.get_node("Line1/D3CheckBox").pressed)]
	configFile.set_value("Config", "size", save_size)
	configFile.set_value("Config", "sphere", save_sphere)
	configFile.set_value("Config", "mines", int(menu.get_node("Line1/Value").text))
	configFile.set_value("Config", "o", margin)
	configFile.set_value("Config", "scale_factor", scale)
	configFile.set_value("Config", "delta_box", int(menu.get_node("Line2/CheckBox").pressed))
	configFile.set_value("Config", "minX", minX)
	configFile.set_value("Config", "minY", minY)
	configFile.set_value("Config", "save_on_exit", int(save_on_exit))
	configFile.set_value("Config", "locale", locale)
	configFile.save(config)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT && ! paused:
		menu._on_Pause_pressed()

func _physics_process(delta):
	if running && ! paused:
		calc_running_time()

func calc_running_time():
	running_time = time_offset + OS.get_ticks_msec() - starting_time

func _process(delta):
	if changed && ! resizing:
		changed = false
		global.scale = clamp(global.scale, 0.5, 4)
		global.write_config()
		settings_menu.update_ui()
		global.resize()

func sanitize_settings():
	remaining = 1
	for i in range(4):
		remaining = remaining * dimensions[i][0]
		if dimensions[i][0] < 3:
			dimensions[i][1] = false
	if remaining < 2:
		dimensions[0][0] = 2
		remaining = 2
	if mines >= remaining:
		mines = remaining - 1
	remaining = remaining - mines
	remaining_mines = mines

func shift(from, to):
	var temp_blocks = []
	for a in range(global.blocks.size()):
		temp_blocks.append([])
		for b in range(global.blocks[0].size()):
			temp_blocks[a].append([])
			for c in range(global.blocks[0][0].size()):
				temp_blocks[a][b].append([])
				for d in range(global.blocks[0][0][0].size()):
					temp_blocks[a][b][c].append([])
	var shift_by = []
	for i in range(4):
		if dimensions[i][1]:
			shift_by.append(to[i] - from[i])
		else:
			shift_by.append(0)
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					for i in range(4):
						blocks[a][b][c][d].coordinates[i] = int(fposmod(blocks[a][b][c][d].coordinates[i] + shift_by[i], global.dimensions[i][0]))
					temp_blocks[blocks[a][b][c][d].coordinates[0]][blocks[a][b][c][d].coordinates[1]][blocks[a][b][c][d].coordinates[2]][blocks[a][b][c][d].coordinates[3]] = blocks[a][b][c][d]
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					blocks[a][b][c][d] = temp_blocks[a][b][c][d]
					blocks[a][b][c][d].recalc_neighbors = true
	board.resize()

func switch_input_state(to, where):
	if ! to == "drag":
		if where.find(-1) == -1:
			blocks[where[0]][where[1]][where[2]][where[3]].highlight(true)
			for i in blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
				global.blocks[i[0]][i[1]][i[2]][i[3]].highlight(true)
		if to == "none":
			input_state = "none"
			if where.find(-1) == -1:
				blocks[where[0]][where[1]][where[2]][where[3]].lowlight(false)
				for i in blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
					blocks[i[0]][i[1]][i[2]][i[3]].lowlight(false)
		elif to == "lowlight this":
			input_state = "lowlight this"
			if where.find(-1) == -1:
				blocks[where[0]][where[1]][where[2]][where[3]].lowlight(true)
				for i in blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
					blocks[i[0]][i[1]][i[2]][i[3]].lowlight(false)
		elif to == "lowlight neighbors":
			input_state = "lowlight neighbors"
			if where.find(-1) == -1:
				blocks[where[0]][where[1]][where[2]][where[3]].lowlight(true)
				for i in blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
					blocks[i[0]][i[1]][i[2]][i[3]].lowlight(true)
	else:
		input_state = "drag"
		if where.find(-1) == -1:
			blocks[where[0]][where[1]][where[2]][where[3]].highlight(false)
			for i in blocks[where[0]][where[1]][where[2]][where[3]].neighbors:
				global.blocks[i[0]][i[1]][i[2]][i[3]].highlight(false)
		if ! drag_start == where:
			global.shift(drag_start, where)

func _input(event):
	var local_position = position
	if event is InputEventMouseButton && ! finished && inside && ! paused:
		if input_state == "none" && event.pressed:
			if event.button_index == 1:
				switch_input_state("lowlight this", local_position)
			elif event.button_index == 2:
				switch_input_state("none", local_position)
				if local_position.find(-1) == -1:
					blocks[local_position[0]][local_position[1]][local_position[2]][local_position[3]].flagged()
			elif event.button_index == 3 && position.find(-1) == -1:
				drag_start = local_position
				switch_input_state("drag", local_position)
		elif input_state == "lowlight this":
			if event.button_index == 1 && ! event.pressed:
				switch_input_state("none", local_position)
				if local_position.find(-1) == -1:
					blocks[local_position[0]][local_position[1]][local_position[2]][local_position[3]].clicked()
			elif event.button_index == 2 && event.pressed:
				switch_input_state("lowlight neighbors", local_position)
		elif input_state == "lowlight neighbors":
			if event.button_index == 1 && ! event.pressed:
				switch_input_state("none", local_position)
				if local_position.find(-1) == -1:
					blocks[local_position[0]][local_position[1]][local_position[2]][local_position[3]].uncover_neighbors()
			elif event.button_index == 2 && ! event.pressed:
				switch_input_state("lowlight this", local_position)
		elif input_state == "drag" && event.button_index == 3 && ! event.pressed:
			blocks[local_position[0]][local_position[1]][local_position[2]][local_position[3]].inside = false
			position = [-1, -1, -1, -1]
			switch_input_state("none", local_position)
		if lost:
			lose()
		elif remaining == 0:
			win()
	if event is InputEventMouseButton && event.pressed && Input.is_key_pressed(OS.find_scancode_from_string("Control")):
		if event.button_index == 4:
			global.scale = global.scale + 0.1
			changed = true
		elif event.button_index == 5:
			global.scale = global.scale - 0.1
			changed = true
		if changed:
			global.scale = clamp(global.scale, 0.5, 4)

func end():
	set_running(false)
	calc_running_time()
	finished = true
	var dir = Directory.new()
	dir.remove(savefile)
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					blocks[a][b][c][d].redraw()

func lose():
	end()
	lose_menu.popup_centered()

func win():
	end()
	win_menu.popup_centered()
	if game_id != "":
		add_win()

func clear_board():
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					blocks[a][b][c][d].neighbors = []
					blocks[a][b][c][d].coordinates = [-1, -1, -1, -1]
					blocks[a][b][c][d].queue_free()
	board.queue_free()
	blocks = []
	inside = false
	paused = false
	finished = false
	started = false
	position = [-1, -1, -1, -1]
	lost = false
	input_state = "none"
	running_time = 0
	set_running(false)
	menu._on_Pause_pressed()
	game_id = ""

func initialize_blocks():
	for a in range(dimensions[0][0]):
		blocks.append([])
		for b in range(dimensions[1][0]):
			blocks[a].append([])
			for c in range(dimensions[2][0]):
				blocks[a][b].append([])
				for d in range(dimensions[3][0]):
					blocks[a][b][c].append(block.instance())
					blocks[a][b][c][d].coordinates = [a, b, c, d]
					blocks[a][b][c][d].get_neighbors()

func new_game():
	var dir = Directory.new()
	dir.remove(savefile)
	menu.get_settigs()
	time_offset = 0
	initialize_blocks()
	sow()
	count()
	board = board_object.instance()
	board.initialize()
	get_tree().get_root().call_deferred("add_child", board)

func sow():
	var pos = [0, 0, 0, 0]
	var num = global.blocks.size() * global.blocks[0].size() * global.blocks[0][0].size() * global.blocks[0][0][0].size()
	var list = range(num)
	var positions = []
	randomize()
	for i in range(mines):
		var x = randi()%list.size()
		positions.append(list[x])
		list.remove(x)
	for i in positions:
		for j in range(4):
			pos[j] = i % dimensions[j][0]
			i = (i - pos[j]) / dimensions[j][0]
		blocks[pos[0]][pos[1]][pos[2]][pos[3]].mine = true

func count():
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					blocks[a][b][c][d].count()

func read_user_files():
	var files = []
	var dir = Directory.new()
	dir.open("user://")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	files.erase("save.sav")
	files.erase("config.cfg")
	files.erase("successes")
	files.sort()
	return files

func read_game_files():
	var files = []
	var dir = Directory.new()
	dir.open(global.exports + "exports/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	files.sort()
	return files