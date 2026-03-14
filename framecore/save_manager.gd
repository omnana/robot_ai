extends Node


const SAVE_DIR: = "user://saves"
const SAVE_PREFIX: = "save_"
const SAVE_EXT: = ".json"

func _ready() -> void :
    if not DirAccess.dir_exists_absolute(SAVE_DIR):
        DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func get_save_path(slot: int) -> String:
    return "%s/%s%d%s" % [SAVE_DIR, SAVE_PREFIX, slot, SAVE_EXT]

func has_save(slot: int) -> bool:
    return FileAccess.file_exists(get_save_path(slot))

func save(slot: int, data: Dictionary) -> bool:
    var path: = get_save_path(slot)
    var file: = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        EventBus.save_completed.emit(slot, false)
        return false
    file.store_string(JSON.stringify(data))
    file.close()
    EventBus.save_completed.emit(slot, true)
    return true

func load(slot: int) -> Dictionary:
    var path: = get_save_path(slot)
    if not FileAccess.file_exists(path):
        EventBus.load_completed.emit(slot, false)
        return {}
    var file: = FileAccess.open(path, FileAccess.READ)
    if file == null:
        EventBus.load_completed.emit(slot, false)
        return {}
    var text: = file.get_as_text()
    file.close()
    var json: = JSON.new()
    var err: = json.parse(text)
    if err != OK:
        EventBus.load_completed.emit(slot, false)
        return {}
    var data: Variant = json.get_data()
    if typeof(data) != TYPE_DICTIONARY:
        EventBus.load_completed.emit(slot, false)
        return {}
    EventBus.load_completed.emit(slot, true)
    return data

func delete_save(slot: int) -> bool:
    var path: = get_save_path(slot)
    if not FileAccess.file_exists(path):
        return true
    return DirAccess.remove_absolute(path) == OK
