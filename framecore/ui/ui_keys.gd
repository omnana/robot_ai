class_name UIRegistry extends RefCounted


static var _keys: Dictionary = {}


static func register(ui_id: StringName, path: String) -> void :
    _keys[ui_id] = UIKey.new(ui_id, path)


static func register_batch(ui_definitions: Dictionary) -> void :
    for ui_id: StringName in ui_definitions:
        var path: String = ui_definitions[ui_id]
        register(ui_id, path)


static func get_key(ui_id: StringName) -> RefCounted:
    return _keys.get(ui_id)


static func has_ui(ui_id: StringName) -> bool:
    return _keys.has(ui_id)


static func get_all_ui_ids() -> Array[StringName]:
    var result: Array[StringName] = []
    result.assign(_keys.keys())
    return result


static func clear() -> void :
    _keys.clear()
