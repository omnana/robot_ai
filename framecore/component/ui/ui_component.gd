class_name UIComponent extends Control


signal shown(data: Dictionary)
signal component_hidden()
signal destroyed()

var _is_showing: bool = false
var _component_name: StringName = &""

func _ready() -> void :
    visible = false
    _on_init()

func _on_init() -> void :
    pass

func show_component(data: Dictionary = {}) -> void :
    if _is_showing:
        return
    _is_showing = true
    visible = true
    _on_show(data)
    shown.emit(data)

func hide_component() -> void :
    if not _is_showing:
        return
    _is_showing = false
    _on_hide()
    visible = false
    component_hidden.emit()

func destroy() -> void :
    hide_component()
    _on_destroy()
    destroyed.emit()
    queue_free()

func is_showing() -> bool:
    return _is_showing

func get_component_name() -> StringName:
    return _component_name

func set_component_name(component_name: StringName) -> void :
    _component_name = component_name

func _on_show(_data: Dictionary) -> void :
    pass

func _on_hide() -> void :
    pass

func _on_destroy() -> void :
    pass
