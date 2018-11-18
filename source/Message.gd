extends WindowDialog

func _ready():
	resize()
	add_to_group("resizable")

func resize():
	$Label.get_font("font").size = 16 * global.scale
	$Label.rect_size = Vector2(0, 0)
	$Label.rect_position.x = global.margin * global.scale
	$Label.rect_position.y = global.margin * global.scale
	rect_size.x = $Label.rect_position.x + $Label.rect_size.x + global.margin * global.scale
	rect_size.y = $Label.rect_position.y + $Label.rect_size.y + global.margin * global.scale

func _on_Sorry_item_rect_changed():
	rect_position.x = clamp(rect_position.x, 0, max(OS.window_size.x - rect_size.x, 0))
	rect_position.y = clamp(rect_position.y, 0, max(OS.window_size.y - rect_size.y, 0))
