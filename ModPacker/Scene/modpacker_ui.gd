@tool
extends VBoxContainer
@onready var file_dialog: FileDialog = $FileDialog
@onready var browse_dir_label: Label = $HBoxContainer/BrowseDirLabel

@onready var mod_name_line_edit: LineEdit = $ModName_LineEdit
@onready var mod_author_line_edit: LineEdit = $ModAuthor_LineEdit
@onready var mod_author_link_line_edit: LineEdit = $ModAuthorLink_LineEdit
@onready var mod_version_line_edit: LineEdit = $ModVersion_LineEdit
@onready var game_version_line_edit: LineEdit = $GameVersion_LineEdit

var mod_export_dir:String

func _on_browse_dir_button_pressed() -> void:
	file_dialog.popup()

func _on_file_dialog_dir_selected(dir: String) -> void:
	browse_dir_label.text = dir
	mod_export_dir = dir

func _on_export_button_pressed() -> void:
	var mod_name = mod_name_line_edit.text
	var mod_author = mod_author_line_edit.text
	var mod_author_link = mod_author_link_line_edit.text
	var mod_version = mod_version_line_edit.text
	var game_version = game_version_line_edit.text
	if mod_export_dir == "":
		print("Error: Mod directory not found")
	if mod_name == "" or mod_author == "" or mod_version == "" or game_version == "":
		print("Error all fields except link must be filled")
	else:
		var mod_file_name = str(mod_name + mod_version).to_lower()
		mod_file_name = mod_file_name.replace(' ',"_")
		mod_file_name = mod_file_name.validate_filename()
		var export_dir = mod_export_dir
		var mod_file_path = export_dir+mod_file_name
		var new_pck = PCKPacker.new()
		new_pck.pck_start(mod_file_path+".pck")
		dir_contents_recursive(new_pck,"res://mod/")
		new_pck.flush(true)
		print(mod_file_path+".pck")

func dir_contents_recursive(new_pck:PCKPacker,path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var filePath = path+"/"+file_name
			if dir.current_is_dir():
				print("Found directory: " + filePath)
				dir_contents_recursive(new_pck,filePath)
			else:
				print("Found file: " + filePath)
				new_pck.add_file(filePath,filePath,false)
			file_name = dir.get_next()
		print("Found all files in the directory")
	else:
		print("An error occurred when trying to access the path.")
