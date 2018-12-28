extends Panel

func _ready():
	switch_locale()
	resize()
	add_to_group("translations")
	add_to_group("resizable")

func switch_locale():
	$Label.text = TranslationServer.translate("RESUME_GAME")
	$Yes.text = TranslationServer.translate("YES")
	$No.text = TranslationServer.translate("NO")

func resize():
	$Label.get_font("font").size = 50 * global.scale
	$Yes.get_font("font").size = 40 * global.scale
	$No.get_font("font").size = 40 * global.scale
	$Label.rect_size = Vector2(0, 0)
	$Yes.rect_size = Vector2(0, 0)
	$No.rect_size = Vector2(0, 0)
	$Label.rect_position.x = (OS.window_size.x - $Label.rect_size.x) / 2
	var margin = (OS.window_size.x - $Yes.rect_size.x - $No.rect_size.x) / 3
	$Yes.rect_position.x = margin
	$No.rect_position.x = 2 * margin + $Yes.rect_size.x
	var sizey = $Label.rect_size.y + $Yes.rect_size.y + global.margin * global.scale
	$Label.rect_position.y = (OS.window_size.y - sizey) / 2
	$Yes.rect_position.y = $Label.rect_position.y + $Label.rect_size.y + global.margin * global.scale
	$No.rect_position.y = $Yes.rect_position.y
	rect_size = OS.window_size

func _on_Yes_pressed():
	global.load_game()
	queue_free()

func _on_No_pressed():
	global.new_game()
	queue_free()