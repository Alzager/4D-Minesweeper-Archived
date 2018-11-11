extends WindowDialog

func _ready():
	switch_locale()
	resize()
	add_to_group("translations")
	add_to_group("resizable")

func switch_locale():
	window_title = TranslationServer.translate("LOSE_TITLE")
	$Label.text = TranslationServer.translate("LOSE")
	$NewGame.text = TranslationServer.translate("RESTART")
	$NewGame.hint_tooltip = TranslationServer.translate("START_TOOLTIP")
	$Close.text = TranslationServer.translate("CLOSE")

func resize():
	$Label.get_font("font").size = 16 * global.scale
	$NewGame.get_font("font").size = 12 * global.scale
	$Close.get_font("font").size = 12 * global.scale
	$Label.rect_size = Vector2(0, 0)
	rect_size.x = $Label.rect_size.x + global.margin * global.scale * 2
	$Label.rect_position.x = global.margin * global.scale
	$Label.rect_position.y = global.margin * global.scale
	$NewGame.rect_size = Vector2(0, 0)
	$NewGame.rect_position.x = $Label.rect_position.x
	$NewGame.rect_position.y = $Label.rect_position.y + $Label.rect_size.y + global.margin * global.scale * 2
	$Close.rect_size = Vector2(0, 0)
	$Close.rect_position.x = rect_size.x - $Close.rect_size.x - global.margin * global.scale * 2
	$Close.rect_position.y = $NewGame.rect_position.y
	rect_size.y = $NewGame.rect_position.y + $NewGame.rect_size.y + global.margin * global.scale * 2

func _on_NewGame_pressed():
	global.clear_board()
	global.new_game()
	hide()

func _on_Close_pressed():
	hide()

func _on_Lose_item_rect_changed():
	rect_position.x = clamp(rect_position.x, 0, max(OS.window_size.x - rect_size.x, 0))
	rect_position.y = clamp(rect_position.y, 0, max(OS.window_size.y - rect_size.y, 0))
