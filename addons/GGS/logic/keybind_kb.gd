extends Node
# value: int
#	Scancode
# action_name
#	Name of the action that'll be affected


func main(value: Dictionary) -> void:
	var target_action: String = value["action_name"]
	var action_list: Array = InputMap.get_action_list(target_action)
	var prev_event: InputEventWithModifiers = Utils.array_find_type(action_list, "InputEventKey")
	if prev_event == null:
		prev_event = Utils.array_find_type(action_list, "InputEventMouseButton")
	var new_event: InputEventWithModifiers
	if value["value"] > 24:
		new_event = InputEventKey.new()
		new_event.scancode = value["value"]
	else:
		new_event = InputEventMouseButton.new()
		new_event.button_index = value["value"]

	InputMap.action_erase_event(target_action, prev_event)
	InputMap.action_add_event(target_action, new_event)
