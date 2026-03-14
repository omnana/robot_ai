








class_name LayerManager
extends RefCounted



static var _instance: LayerManager = null



var _root: Node2D = null
var _background_layer: Node2D = null
var _character_layer: Node2D = null
var _bullet_layer: Node2D = null
var _effect_layer: Node2D = null
var _ui_layer: CanvasLayer = null
var _is_initialized: bool = false



static func get_instance() -> LayerManager:
    if _instance == null:
        _instance = LayerManager.new()
    return _instance



static func setup(root: Node2D) -> void :
    var instance: = get_instance()

    if instance._is_initialized:
        if instance._root == null or not is_instance_valid(instance._root):
            instance._is_initialized = false
            instance._root = null
            instance._background_layer = null
            instance._character_layer = null
            instance._bullet_layer = null
            instance._effect_layer = null
            instance._ui_layer = null
    if instance._is_initialized:
        return
    instance._is_initialized = true
    instance._setup_layers(root)


func _setup_layers(root: Node2D) -> void :
    _root = root

    _background_layer = _create_layer("BackgroundLayer", LayerConstants.Z_BACKGROUND)
    _character_layer = _create_layer("CharacterLayer", LayerConstants.Z_CHARACTER)
    _bullet_layer = _create_layer("BulletLayer", LayerConstants.Z_BULLET)
    _effect_layer = _create_layer("EffectLayer", LayerConstants.Z_EFFECT)
    _ui_layer = _create_canvas_layer("UILayer", LayerConstants.Z_UI)

    _character_layer.y_sort_enabled = true

    print("[LayerManager] 层级管理器初始化完成")


func _create_layer(name: String, z_index: int) -> Node2D:
    var layer: = Node2D.new()
    layer.name = name
    layer.z_index = z_index
    _root.add_child(layer)
    return layer


func _create_canvas_layer(name: String, layer_index: int) -> CanvasLayer:
    var layer: = CanvasLayer.new()
    layer.name = name
    layer.layer = layer_index
    _root.add_child(layer)
    return layer



static func add_background(node: Node2D) -> void :
    var instance: = get_instance()
    if instance._background_layer == null:
        push_warning("[LayerManager] 背景层未初始化，添加到根节点")
        instance._root.add_child(node)
        return
    instance._background_layer.add_child(node)


static func add_character(node: Node2D) -> void :
    var instance: = get_instance()
    if instance._character_layer == null:
        push_warning("[LayerManager] 角色层未初始化，添加到根节点")
        instance._root.add_child(node)
        return
    instance._character_layer.add_child(node)


static func add_bullet(node: Node2D) -> void :
    var instance: = get_instance()
    if instance._bullet_layer == null:
        push_warning("[LayerManager] 子弹层未初始化，添加到根节点")
        instance._root.add_child(node)
        return
    instance._bullet_layer.add_child(node)


static func add_effect(node: Node2D) -> void :
    var instance: = get_instance()
    if instance._effect_layer == null:
        push_warning("[LayerManager] 特效层未初始化，添加到根节点")
        instance._root.add_child(node)
        return
    instance._effect_layer.add_child(node)


static func add_ui(node: Control) -> void :
    var instance: = get_instance()
    if instance._ui_layer == null:
        push_warning("[LayerManager] UI层未初始化，添加到根节点")
        instance._root.add_child(node)
        return
    instance._ui_layer.add_child(node)



static func get_background_layer() -> Node2D:
    return get_instance()._background_layer


static func get_character_layer() -> Node2D:
    return get_instance()._character_layer


static func get_bullet_layer() -> Node2D:
    return get_instance()._bullet_layer


static func get_effect_layer() -> Node2D:
    return get_instance()._effect_layer


static func get_ui_layer() -> CanvasLayer:
    return get_instance()._ui_layer



static func clear_all() -> void :
    var instance: = get_instance()
    if instance._background_layer != null:
        for child in instance._background_layer.get_children():
            child.queue_free()
    if instance._character_layer != null:
        for child in instance._character_layer.get_children():
            child.queue_free()
    if instance._bullet_layer != null:
        for child in instance._bullet_layer.get_children():
            child.queue_free()
    if instance._effect_layer != null:
        for child in instance._effect_layer.get_children():
            child.queue_free()
    if instance._ui_layer != null:
        for child in instance._ui_layer.get_children():
            child.queue_free()


static func clear_layer(layer_name: String) -> void :
    var instance: = get_instance()
    var layer: Node = null
    match layer_name:
        "background":
            layer = instance._background_layer
        "character":
            layer = instance._character_layer
        "bullet":
            layer = instance._bullet_layer
        "effect":
            layer = instance._effect_layer
        "ui":
            layer = instance._ui_layer

    if layer != null:
        for child in layer.get_children():
            child.queue_free()
