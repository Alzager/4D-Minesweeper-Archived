extends LineEdit

func _enter_tree():
	connect("gui_input", self, "_on_gui_input")
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")

func _on_gui_input(event):
	var select = false
	if has_focus() && (event is InputEventMouseButton || event is InputEventKey) && event.pressed && ! Input.is_key_pressed(OS.find_scancode_from_string("Control")):
		if (event is InputEventMouseButton && event.button_index == 4) || (event is InputEventKey && event.as_text() == "Up"):
			text = str(clamp(round(float(text) * 10 + 1) / 10, 0.5, 4))
			select = true
		elif (event is InputEventMouseButton && event.button_index == 5) || (event is InputEventKey && event.as_text() == "Down"):
			text = str(clamp(round(float(text) * 10 - 1) / 10, 0.5, 4))
			select = true
	if has_focus() && event is InputEventMouseButton:
		select = true
	if select:
		select_all()

func _on_focus_entered():
	select_all()

func _on_focus_exited():
	deselect()