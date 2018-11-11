extends WindowDialog

func _ready():
	switch_locale()
	resize()
	add_to_group("translations")
	add_to_group("resizable")

func switch_locale():
	window_title = TranslationServer.translate("START_NEW")
	$Label.text = TranslationServer.translate("START_NEW")
	$Yes.text = TranslationServer.translate("YES")
	$No.text = TranslationServer.translate("NO")

func resize():
	$Label.get_font("font").size = 16 * global.scale
	$Yes.get_font("font").size = 12 * global.scale
	$No.get_font("font").size = 12 * global.scale
	$Label.rect_size = Vector2(0, 0)
	$Yes.rect_size = Vector2(0, 0)
	$No.rect_size = Vector2(0, 0)
	rect_size.x = $Label.rect_size.x + global.margin * global.scale * 2
	$Label.rect_position.x = global.margin * global.scale
	$Yes.rect_position.y = $Label.rect_size.y
	$No.rect_position.y = $Yes.rect_position.y
	rect_size.y = $Yes.rect_position.y + $Yes.rect_size.y + global.margin * global.scale
	$Yes.rect_position.x = global.margin * global.scale
	$No.rect_position.x = rect_size.x - $No.rect_size.x - global.margin * global.scale

func _on_Yes_pressed():
	global.clear_board()
	global.new_game()
	hide()

func _on_No_pressed():
	hide()


func _on_NewGame_item_rect_changed():
	rect_position.x = clamp(rect_position.x, 0, max(OS.window_size.x - rect_size.x, 0))
	rect_position.y = clamp(rect_position.y, 0, max(OS.window_size.y - rect_size.y, 0))
