extends Node

# Main_scene is the entry point for Godot Engine. 
# This scene sets up the main menu scene to load.

func _ready():
	var main_menu_path = ProjectSettings.get_setting("escoria/main/main_menu_scene")
	var main_menu_scene = load(main_menu_path).instance()
	get_tree().get_root().call_deferred("add_child", main_menu_scene)
	escoria.set_main_menu(main_menu_scene)
	

