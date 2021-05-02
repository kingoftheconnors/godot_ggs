tool
extends Button

enum Type {Bool, OptionList, TextField, NumberField, ArrowList}

# Scene Tree
onready var PopMenu: PopupMenu = $PopupMenu

# Resources
onready var BoolComponent: PackedScene = preload("../../components/boolean/ggsBool.tscn")
onready var HSliderComponent: PackedScene = preload("../../components/slider/ggsHSlider.tscn")
onready var VSliderComponent: PackedScene = preload("../../components/slider/ggsVSlider.tscn")
onready var OptionListComponent: PackedScene = preload("../../components/option_list/ggsOptionList.tscn")
onready var TextFieldComponent: PackedScene = preload("../../components/text_field/ggsTextField.tscn")
onready var NumberFieldComponent: PackedScene = preload("../../components/number_field/ggsNumberField.tscn")
onready var KeybindKbComponent: PackedScene = preload("../../components/keybind/ggsKeybindKb.tscn")
onready var KeybindGpComponent: PackedScene = preload("../../components/keybind/ggsKeybindGp.tscn")
onready var ArrowListComponent: PackedScene = preload("../../components/arrow_list/ggsArrowList.tscn")


func _ready() -> void:
	_populate_menu()


func _populate_menu() -> void:
	var MainMenu: PopupMenu = PopMenu
	var SliderSub: PopupMenu = PopupMenu.new()
	var KeybindSub: PopupMenu = PopupMenu.new()
	MainMenu.clear()
	
	KeybindSub.set_name("KeybindSub")
	KeybindSub.add_item("Keyboard")
	KeybindSub.add_item("Gamepad")
	KeybindSub.connect("index_pressed", self, "_on_Keybind_item_selected")
	
	SliderSub.set_name("SliderSub")
	SliderSub.add_item("Horizontal")
	SliderSub.add_item("Vertical")
	SliderSub.connect("index_pressed", self, "_on_Slider_item_selected")
	
	MainMenu.add_item("Boolean")
	MainMenu.add_item("Option List")
	MainMenu.add_item("Text Field")
	MainMenu.add_item("Number Field")
	MainMenu.add_item("Arrow List")
	MainMenu.add_child(SliderSub)
	MainMenu.add_child(KeybindSub)
	MainMenu.add_submenu_item("Slider", "SliderSub")
	MainMenu.add_submenu_item("Keybind", "KeybindSub")
	MainMenu.connect("index_pressed", self, "_on_Main_item_selected")


func _on_Main_item_selected(index: int) -> void:
	var instance
	match index:
		Type.Bool:
			instance = BoolComponent.instance()
		Type.OptionList:
			instance = OptionListComponent.instance()
		Type.TextField:
			instance = TextFieldComponent.instance()
		Type.NumberField:
			instance = NumberFieldComponent.instance()
		Type.ArrowList:
			instance = ArrowListComponent.instance()
	
	_add_node(instance)


func _on_Slider_item_selected(index: int) -> void:
	var instance
	match index:
		0:
			instance = HSliderComponent.instance()
		1:
			instance = VSliderComponent.instance()
	
	_add_node(instance)


func _on_Keybind_item_selected(index: int) -> void:
	var instance
	match index:
		0:
			instance = KeybindKbComponent.instance()
		1:
			instance = KeybindGpComponent.instance()
	
	_add_node(instance)


func _add_node(node: Object) -> void:
	var Editor: EditorPlugin = EditorPlugin.new()
	var Interface: EditorInterface = Editor.get_editor_interface()
	var Selection: EditorSelection = Interface.get_selection()
	var selected_nodes: Array = Selection.get_selected_nodes()
	
	if selected_nodes != []:
		if selected_nodes.size() == 1:
			selected_nodes[0].add_child(node)
			node.owner = get_tree().edited_scene_root
		else:
			printerr("GGS - AddNode: Cannot add to multiple nodes. Please select one node only.")
			return
	else:
		printerr("GGS - AddNode: Cannot add to nothing. Please select a node first.")
		return
	
	if ggsManager.ggs_data["auto_select_new_nodes"]:
		Selection.clear()
		Selection.add_node(node)
		Interface.inspect_object(node, "setting_index", true)
	Interface.save_scene()


func _on_AddNode_toggled(button_pressed: bool) -> void:
	if button_pressed:
		var offset: Vector2 = Vector2(0, rect_size.y + 2)
		PopMenu.rect_global_position = rect_global_position + offset
		PopMenu.popup()


func _on_PopupMenu_popup_hide() -> void:
	yield(get_tree().create_timer(0.01), "timeout")
	pressed = false
