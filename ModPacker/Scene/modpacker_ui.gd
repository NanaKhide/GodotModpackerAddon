@tool
extends VBoxContainer
#This gets all UI components that are important for user input
@onready var file_dialog: FileDialog = $FileDialog
@onready var browse_dir_label: Label = $HBoxContainer/BrowseDirLabel
@onready var mod_name_line_edit: LineEdit = $ModName_LineEdit
@onready var mod_author_line_edit: LineEdit = $ModAuthor_LineEdit
@onready var mod_author_link_line_edit: LineEdit = $ModAuthorLink_LineEdit
@onready var mod_version_line_edit: LineEdit = $ModVersion_LineEdit
@onready var game_version_line_edit: LineEdit = $GameVersion_LineEdit

# set upon the export file dialoge selected a directory
var mod_export_dir:String =""

#when the browse directory button is pressed the popup window is shown
func _on_browse_dir_button_pressed() -> void:
	file_dialog.popup()

#when you select a file in the file browser popup it will assign mod_export_dir the path
func _on_file_dialog_dir_selected(dir: String) -> void:
	browse_dir_label.text = dir
	mod_export_dir = dir

#the main logic for everything starts here
func _on_export_button_pressed() -> void:
	#these are just all values provided by the user in the line edits
	var mod_name = mod_name_line_edit.text
	var mod_author = mod_author_line_edit.text
	var mod_author_link = mod_author_link_line_edit.text
	var mod_version = mod_version_line_edit.text
	var game_version = game_version_line_edit.text
	
	var _mod_dir = DirAccess.open("res://")
	assert(_mod_dir.dir_exists("mod/"),"You must create a mod directory: red://mod/")
	
	#this writes everything into a config file
	#if the mod_export_directory is empty, the user didnt assign an export directory so we just stop the logic
	if mod_export_dir == "":
		print("Error: Mod directory not found")
	#same thing if mod_name, mod_author, mod_version or game_version isnt provided
	elif mod_name == "" or mod_author == "" or mod_version == "" or game_version == "":
		print("Error all fields except link must be filled")
	else:
		#if everything looks fine we write the new config file
		write_config(mod_name,mod_author,mod_author_link,mod_version,game_version)
		
		#we generate the mod file name:
		var mod_file_name = str(mod_name + mod_version).to_lower()
		#and make sure that its a valid filename
		mod_file_name = mod_file_name.replace(' ',"_")
		mod_file_name = mod_file_name.validate_filename()
		var mod_file_path = mod_export_dir+"/"+mod_file_name
		#then we start to make the PCK file
		var new_pck = PCKPacker.new()
		new_pck.pck_start(mod_file_path+".pck")
		# into the pck file we add everything under res://mod
		dir_contents_recursive(new_pck,"res://mod")
		new_pck.flush(true)
		print("Mod exported!")

func write_config(mod_name,mod_author,mod_author_link,mod_version,game_version):
	var config_file = ConfigFile.new()
	config_file.set_value("Mod_Config","ModName",mod_name)
	config_file.set_value("Mod_Config","ModAuthor",mod_author)
	config_file.set_value("Mod_Config","ModAuthorLink",mod_author_link)
	config_file.set_value("Mod_Config","ModVersion",mod_version)
	config_file.set_value("Game_Config","GameVersion",game_version)
	config_file.save("res://mod/Mod_Config.config")

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
		print("Found all files in the directory", path)
	else:
		print("An error occurred when trying to access the path.")
