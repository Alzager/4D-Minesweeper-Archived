extends WindowDialog

func _ready():
	switch_locale()
	resize()
	add_to_group("translations")
	add_to_group("resizable")

func switch_locale():
	window_title = TranslationServer.translate("WIN_TITLE")
	$Label.text = TranslationServer.translate("WIN")
	$Export.text = TranslationServer.translate("EXPORT")
	$NewGame.text = TranslationServer.translate("RESTART")
	$NewGame.hint_tooltip = TranslationServer.translate("START_TOOLTIP")
	$Close.text = TranslationServer.translate("CLOSE")
	_on_ExportLineEdit_text_changed()

func resize():
	$Label.get_font("font").size = 16 * global.scale
	$Export.get_font("font").size = 12 * global.scale
	$NewGame.get_font("font").size = 12 * global.scale
	$Close.get_font("font").size = 12 * global.scale
	$Label.rect_size = Vector2(0, 0)
	rect_size.x = $Label.rect_size.x + global.margin * global.scale * 2
	$Label.rect_position.x = global.margin * global.scale
	$Label.rect_position.y = global.margin * global.scale
	$Export.rect_size = Vector2(0, 0)
	$Export.rect_position.x = $Label.rect_position.x
	$Export.rect_position.y = $Label.rect_position.y + $Label.rect_size.y + global.margin * global.scale * 2
	$ExportLineEdit.rect_size.y = $Export.rect_size.y
	$ExportLineEdit.rect_size.x = 100 * global.scale
	$ExportLineEdit.rect_position.x = rect_size.x - $ExportLineEdit.rect_size.x - global.margin * global.scale * 2
	$ExportLineEdit.rect_position.y = $Export.rect_position.y
	$NewGame.rect_size = Vector2(0, 0)
	$NewGame.rect_position.x = $Label.rect_position.x
	$NewGame.rect_position.y = $Export.rect_position.y + $Export.rect_size.y + global.margin * global.scale * 2
	$Close.rect_size = Vector2(0, 0)
	$Close.rect_position.x = rect_size.x - $Close.rect_size.x - global.margin * global.scale * 2
	$Close.rect_position.y = $NewGame.rect_position.y
	rect_size.y = $NewGame.rect_position.y + $NewGame.rect_size.y + global.margin * global.scale * 2

func _on_Export_pressed():
	global.export_game($ExportLineEdit.text)

func _on_ExportLineEdit_text_changed(new_text = $ExportLineEdit.text):
	var files = []
	files = global.read_user_files()
	if files.has(new_text):
		$ExportLineEdit.add_color_override("font_color", Color(1, 0, 0))
		$ExportLineEdit.hint_tooltip = TranslationServer.translate("EXISTS")
		$Export.add_color_override("font_color", Color(1, 0, 0))
		$Export.add_color_override("font_color_hover", Color(1, 0, 0))
		$Export.hint_tooltip = TranslationServer.translate("EXISTS")
	else:
		$ExportLineEdit.add_color_override("font_color", Color(1, 1, 1))
		$ExportLineEdit.hint_tooltip = TranslationServer.translate("EXPORT_NAME_TOOLTIP")
		$Export.add_color_override("font_color", Color(1, 1, 1))
		$Export.add_color_override("font_color_hover", Color(1, 1, 1))
		$Export.hint_tooltip = TranslationServer.translate("EXPORT_TOOLTIP")
	if ! new_text == "" && ! new_text == "successes" && ! new_text == "save.sav" && ! new_text == "config.cfg" && ! "/" in new_text && ! "\\" in new_text && ! ":" in new_text && ! "*" in new_text && ! "\"" in new_text && ! "?" in new_text && ! "<" in new_text && ! ">" in new_text && ! "|" in new_text:
		$Export.disabled = false
	else:
		$Export.disabled = true

func _on_NewGame_pressed():
	global.clear_board()
	global.new_game()
	hide()

func _on_Close_pressed():
	hide()

func _on_Win_item_rect_changed():
	rect_position.x = clamp(rect_position.x, 0, max(OS.window_size.x - rect_size.x, 0))
	rect_position.y = clamp(rect_position.y, 0, max(OS.window_size.y - rect_size.y, 0))
