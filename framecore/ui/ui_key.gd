class_name UIKey extends RefCounted


var id: StringName = &""
var path: String = ""

func _init(ui_id: StringName = &"", ui_path: String = "") -> void :
    id = ui_id
    path = ui_path
