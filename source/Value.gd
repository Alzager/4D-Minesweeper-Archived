extends LineEdit

func _input(event):
	if has_focus() && event is InputEventMouseButton && event.pressed && ! Input.is_key_pressed(OS.find_scancode_from_string("Control")):
		if event.button_index == 4:
			text = str(int(text) + 1)
		elif event.button_index == 5:
			text = str(max(int(text) - 1, 1))
