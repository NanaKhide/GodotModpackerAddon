@tool
extends EditorPlugin

const PluginUI = preload("res://addons/fs-etd-modpacker/Scene/modpacker_ui.tscn")
var ui_instance

func _enter_tree() -> void:
	ui_instance = PluginUI.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL,ui_instance)


func _exit_tree() -> void:
	remove_control_from_docks(ui_instance)
	ui_instance.queue_free()
