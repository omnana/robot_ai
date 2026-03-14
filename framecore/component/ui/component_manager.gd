extends Node


var _components: Dictionary = {}
var _component_paths: Dictionary = {}

func _ready() -> void :
    _register_builtin_components()

func _register_builtin_components() -> void :
    register_component(&"UIMessageBox", "res://resources/components/message_box.tscn")
    register_component(&"UIToast", "res://resources/components/toast.tscn")
    register_component(&"UIProgressBar", "res://resources/components/progress_bar.tscn")
    register_component(&"UITooltip", "res://resources/components/tooltip.tscn")
    register_component(&"UIListView", "res://resources/components/list_view.tscn")

func register_component(component_name: StringName, scene_path: String) -> void :
    _component_paths[component_name] = scene_path

func get_component(component_name: StringName) -> UIComponent:
    if _components.has(component_name):
        return _components[component_name]

    if not _component_paths.has(component_name):
        push_error("ComponentManager: component not registered - %s" % component_name)
        return null

    var path: String = _component_paths[component_name]
    if not ResourceLoader.exists(path):
        push_error("ComponentManager: scene not found - %s" % path)
        return null

    var packed: = load(path) as PackedScene
    if packed == null:
        push_error("ComponentManager: failed to load scene - %s" % path)
        return null

    var instance: = packed.instantiate() as UIComponent
    if instance == null:
        push_error("ComponentManager: instance is not UIComponent - %s" % path)
        return null

    instance.set_component_name(component_name)
    add_child(instance)
    _components[component_name] = instance
    return instance

func show_component(component_name: StringName, data: Dictionary = {}) -> UIComponent:
    var component: = get_component(component_name)
    if component:
        component.show_component(data)
    return component

func hide_component(component_name: StringName) -> void :
    if _components.has(component_name):
        _components[component_name].hide_component()

func hide_all() -> void :
    for component_name in _components:
        _components[component_name].hide_component()

func release_component(component_name: StringName) -> void :
    if _components.has(component_name):
        var component: UIComponent = _components[component_name]
        component.destroy()
        _components.erase(component_name)

func clear() -> void :
    for component_name in _components.keys():
        release_component(component_name)
    _components.clear()

func has_component(component_name: StringName) -> bool:
    return _components.has(component_name)

func is_component_showing(component_name: StringName) -> bool:
    if _components.has(component_name):
        return _components[component_name].is_showing()
    return false
