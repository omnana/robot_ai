extends Node


var _layer: CanvasLayer
var _stack: Array = []

func _ready() -> void :
    _layer = CanvasLayer.new()
    _layer.layer = 10
    add_child(_layer)

func open(key: RefCounted, data: Dictionary = {}) -> void :
    if key == null:
        push_error("UIManager.open: key is null")
        return

    var ui_id: StringName = key.id
    var path: String = key.path

    if path.is_empty():
        push_error("UIManager.open: invalid path for key %s" % ui_id)
        return

    var packed: PackedScene = load(path) as PackedScene
    if packed == null:
        push_error("UIManager.open: failed to load %s" % path)
        return

    _instantiate_and_show(ui_id, packed, data)

func _instantiate_and_show(ui_id: StringName, packed: PackedScene, data: Dictionary) -> void :
    var instance: Node = packed.instantiate()
    if not (instance is CanvasItem or instance is CanvasLayer):
        push_error("UIManager: scene root must be CanvasItem or CanvasLayer")
        instance.queue_free()
        return

    if instance is CanvasLayer:
        _layer.add_child(instance)
        _stack.append({"id": ui_id, "node": instance as CanvasLayer})
    elif instance is CanvasItem:
        _layer.add_child(instance)
        _stack.append({"id": ui_id, "node": instance as CanvasItem})

    if instance.has_method("show_panel"):
        instance.show_panel(data)

    EventBus.ui_opened.emit(ui_id)

func close() -> void :
    if _stack.is_empty():
        return
    var entry: Dictionary = _stack.pop_back()
    var ui_id: StringName = entry.get("id", &"")
    EventBus.ui_closed.emit(ui_id)
    if entry.node.has_method("close_panel"):
        entry.node.close_panel()
    else:
        entry.node.queue_free()

func close_ui(key: RefCounted) -> void :
    if key == null:
        push_error("UIManager.close_ui: key is null")
        return

    var ui_id: StringName = key.id
    for i in range(_stack.size() - 1, -1, -1):
        var entry: Dictionary = _stack[i]
        if entry.get("id") == ui_id:
            _stack.remove_at(i)
            EventBus.ui_closed.emit(ui_id)
            if entry.node.has_method("close_panel"):
                entry.node.close_panel()
            else:
                entry.node.queue_free()
            return

func close_all() -> void :
    while not _stack.is_empty():
        close()

func get_stack_count() -> int:
    return _stack.size()

func has_open_ui() -> bool:
    return not _stack.is_empty()

func get_top_ui_id() -> StringName:
    if _stack.is_empty():
        return &""
    return _stack.back().get("id", &"")

func is_ui_open(ui_id: StringName) -> bool:
    for entry in _stack:
        if entry.get("id") == ui_id:
            return true
    return false
