@tool
extends EditorPlugin

const MODPACKER_UI = preload("res://addons/ModPacker/Scene/modpacker_ui.tscn")
var ui_instance

func _enter_tree() -> void:
	ui_instance = MODPACKER_UI.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL,ui_instance)


func _exit_tree() -> void:
	remove_control_from_docks(ui_instance)
	ui_instance.queue_free()
