extends ScrollContainer

func _ready():
	resize()
	add_to_group("resizable")
	global.menu.update_remaining()

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
	$Area2D/Collision.shape.extents = rect_size / 2
	$Area2D/Collision.position = $Area2D/Collision.shape.extents
	for a in range(global.blocks.size()):
		for b in range(global.blocks[0].size()):
			for c in range(global.blocks[0][0].size()):
				for d in range(global.blocks[0][0][0].size()):
					global.blocks[a][b][c][d].position = Vector2(block_size * global.blocks[a][b][c][d].coordinates[0] + superblock_size.x * global.blocks[a][b][c][d].coordinates[2] + ceil(global.margin * global.scale), block_size * global.blocks[a][b][c][d].coordinates[1] + superblock_size.y * global.blocks[a][b][c][d].coordinates[3] + ceil(global.margin * global.scale))
	global.reposition()