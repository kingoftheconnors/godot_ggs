extends Button

export(int, 0, 99) var setting_index: int
var script_instance: Object

# Resources
onready var ConfirmPopup: PackedScene = preload("KeybindConfirm.tscn")


func _ready() -> void:
	# Load and set display value
	var current = ggsManager.settings_data[str(setting_index)]["current"]
	var value: int
	
	if ggsManager.ggs_data["gamepad_use_glyphs"]:
		icon = load(ggsManager.ggs_data["gamepad_glyphs_texture"]) as AnimatedTexture
		if current == null:
			value = ggsManager.settings_data[str(setting_index)]["default"][1]
		else:
			value = ggsManager.settings_data[str(setting_index)]["current"][1]
		icon.current_frame = value
	else:
		if current == null:
			value = ggsManager.settings_data[str(setting_index)]["default"][1]
		else:
			value = ggsManager.settings_data[str(setting_index)]["current"][1]
		text = _get_actual_string(Input.get_joy_button_string(value))
	
	# Load Script
	var script: Script = load(ggsManager.settings_data[str(setting_index)]["logic"])
	script_instance = script.new()
	
	# Connect signal
	connect("pressed", self, "_on_pressed")


func _on_pressed() -> void:
	var instance: PopupPanel = ConfirmPopup.instance()
	instance.type = 1
	add_child(instance)
	instance.popup_centered()
	instance.connect("confirmed", self, "_on_ConfirmPopup_confirmed", [], CONNECT_ONESHOT)


func _on_ConfirmPopup_confirmed(event: InputEventJoypadButton) -> void:
	# Update save value
	var current = ggsManager.settings_data[str(setting_index)]["current"]
	var target_action = ggsManager.settings_data[str(setting_index)]["default"][0]
	if current == null:
		ggsManager.settings_data[str(setting_index)]["current"] = [target_action, event.button_index]
	else:
		ggsManager.settings_data[str(setting_index)]["current"][1] = event.button_index
	ggsManager.save_settings_data()
	
	# Update display value
	if ggsManager.ggs_data["gamepad_use_glyphs"]:
		icon.current_frame = event.button_index
	else:
		text = _get_actual_string(Input.get_joy_button_string(event.button_index))
	
	# Execute the logic script
	script_instance.main(ggsManager.settings_data[str(setting_index)]["current"])


func _get_actual_string(button_string: String) -> String:
	# Based on Xbox Controller
	var glyphs: Dictionary = {
		"Face Button Right": "B",
		"Face Button Top": "Y",
		"Face Button Left": "X",
		"Face Button Bottom": "A",
		"L": "L1",
		"L2": "L2",
		"L3": "L3",
		"R": "R1",
		"R2": "R2",
		"R3": "R3",
		"DPAD Up": "Up",
		"DPAD Left": "Left",
		"DPAD Down": "Down",
		"DPAD Right": "Right",
		"Select": "Select",
		"Start": "Start",
	}
	return glyphs[button_string]
