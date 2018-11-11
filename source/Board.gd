extends ScrollContainer

func _ready():
	resize()
	add_to_group("resizable")
	global.menu.update_remaining()

func _physics_process(delta):
	if 0 <= get_local_mouse_position().x && 0 <= get_local_mouse_position().y && get_local_mouse_position().x <= rect_size.x && get_local_mouse_position().y <= rect_size.y && ! global.settings_menu.is_visible_in_tree() && ! global.newgame_menu.is_visible_in_tree() && ! global.win_menu.is_visible_in_tree() && ! global.lose_menu.is_visible_in_tree() && ! global.sorry_menu.is_visible_in_tree():
		global.inside = true
	else:
		if global.position.find(-1) == -1:
			global.blocks[global.position[0]][global.position[1]][global.position[2]][global.position[3]].exited()
		global.inside = false
		global.switch_input_state("none", global.position)

func initialize():
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					$Control.add_child(global.blocks[a][b][c][d])

func resize():
	global.blocks[0][0][0][0].resize()
	var block_size = global.blocks[0][0][0][0].get_node("Border").rect_size.x
	var superblock_size = Vector2(block_size * global.blocks.size() + ceil(global.margin * global.scale), block_size * global.blocks[0].size() + ceil(global.margin * global.scale))
	$Control.rect_min_size = Vector2(superblock_size.x * global.blocks[0][0].size() + ceil(global.margin * global.scale), superblock_size.y * global.blocks[0][0][0].size() + ceil(global.margin * global.scale))
	rect_size.x = min(OS.window_size.x, $Control.rect_min_size.x + 12)
	rect_size.y = min(OS.window_size.y - global.menu.rect_size.y - global.margin, $Control.rect_min_size.y + 12)
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					global.blocks[a][b][c][d].position = Vector2(block_size * global.blocks[a][b][c][d].coordinates[0] + superblock_size.x * global.blocks[a][b][c][d].coordinates[2] + ceil(global.margin * global.scale), block_size * global.blocks[a][b][c][d].coordinates[1] + superblock_size.y * global.blocks[a][b][c][d].coordinates[3] + ceil(global.margin * global.scale))
	global.reposition()