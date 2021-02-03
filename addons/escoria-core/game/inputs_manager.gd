tool
extends Node

onready var hover_stack : Array = []
onready var hotspot_focused : String = ""


func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("esc_show_debug_prompt"):
		escoria.main.get_node("layers/debug_layer/esc_prompt_popup").popup()

###################################################################################

func _on_left_click_on_bg(position : Vector2):
	if hotspot_focused.empty():
		printt("Left click on background at ", str(position))
		escoria.main.current_scene.game.left_click_on_bg(position)


func _on_double_left_click_on_bg(position : Vector2):
	if hotspot_focused.empty():
		printt("Double left click on background at ", str(position))
		escoria.main.current_scene.game.left_double_click_on_bg(position)


func _on_right_click_on_bg(position : Vector2):
	if hotspot_focused.empty():
		printt("Right click on background at ", str(position))
		escoria.main.current_scene.game.right_click_on_bg(position)

##################################################################################

func _on_mouse_left_click_inventory_item(inventory_item_global_id, event : InputEvent) -> void:
	printt("Inventory item left clicked ", inventory_item_global_id)
	escoria.main.current_scene.game.left_click_on_inventory_item(inventory_item_global_id, event)

func _on_mouse_right_click_inventory_item(inventory_item_global_id, event : InputEvent) -> void:
	printt("Inventory item right clicked ", inventory_item_global_id)
	escoria.main.current_scene.game.right_click_on_inventory_item(inventory_item_global_id, event)

func _on_mouse_double_left_click_inventory_item(inventory_item_global_id, event : InputEvent) -> void:
	printt("Inventory item double left clicked ", inventory_item_global_id)
	escoria.main.current_scene.game.left_double_click_on_inventory_item(inventory_item_global_id, event)

func _on_mouse_entered_inventory_item(inventory_item_global_id) -> void:
	printt("Inventory item focused ", inventory_item_global_id)
	escoria.main.current_scene.game.inventory_item_focused(inventory_item_global_id)

func _on_mouse_exited_inventory_item() -> void:
	printt("Inventory item unfocused")
	escoria.main.current_scene.game.inventory_item_unfocused()


##################################################################################

func _on_mouse_entered_item(item : ESCItem) -> void:
	printt("Item focused : ", item.global_id)
	
	if !hover_stack.empty():
		if item.z_index < hover_stack.back().z_index:
			hover_stack.insert(hover_stack.size()-1, item)
		else:
			hover_stack.push_back(item)
	else:
		hover_stack.push_back(item)
	
	hotspot_focused = hover_stack.back().global_id
	escoria.main.current_scene.game.element_focused(item.global_id)


func _on_mouse_exited_item(item : ESCItem) -> void:
	printt("Item unfocused : ", item.global_id)
	hover_stack.erase(item)
	if hover_stack.empty():
		hotspot_focused = ""
		escoria.main.current_scene.game.element_unfocused()
	else:
		hotspot_focused = hover_stack.back().global_id
		escoria.main.current_scene.game.element_focused(hotspot_focused)
	
	
func _on_mouse_left_clicked_item(item_global_id : String, event : InputEvent) -> void:
	printt("Item left clicked", item_global_id, event)
	escoria.main.current_scene.game.left_click_on_item(item_global_id, event)

func _on_mouse_left_double_clicked_item(item_global_id : String, event : InputEvent) -> void:
	printt("Item left double clicked", item_global_id, event)
	escoria.main.current_scene.game.left_double_click_on_item(item_global_id, event)

func _on_mouse_right_clicked_item(item_global_id : String, event : InputEvent) -> void:
	printt("Item right clicked", item_global_id, event)
	escoria.main.current_scene.game.right_click_on_item(item_global_id, event)


##################################################################################

func _on_mousewheel_action(direction : int):
	escoria.main.current_scene.game.mousewheel_action(direction)
