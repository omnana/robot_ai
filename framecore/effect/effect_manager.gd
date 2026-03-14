extends Node





var _effect_types: Dictionary = {}


var _active_effects: Array = []


var _effect_layer: Node2D = null




func setup(effect_layer: Node2D) -> void :
    _effect_layer = effect_layer






func register_type(type_name: String, scene_path: String, pool_size: int = 10) -> void :
    if _effect_types.has(type_name):
        push_warning("[EffectManager] 特效类型已注册: " + type_name)
        return

    var prefab = load(scene_path) as PackedScene
    if prefab == null:
        push_error("[EffectManager] 无法加载特效场景: " + scene_path)
        return

    _effect_types[type_name] = {
        "prefab": prefab
    }

    print("[EffectManager] 注册特效类型: " + type_name)






func spawn(type_name: String, params: Dictionary = {}) -> Node:
    if not _effect_types.has(type_name):
        push_error("[EffectManager] 特效类型未注册: " + type_name)
        return null

    var type_data = _effect_types[type_name]
    var prefab = type_data["prefab"]

    var effect = prefab.instantiate()
    if effect == null:
        push_error("[EffectManager] 无法实例化特效: " + type_name)
        return null

    _active_effects.append(effect)


    if _effect_layer != null:
        _effect_layer.add_child(effect)
    else:
        add_child(effect)


    if params.has("position"):
        effect.global_position = params["position"]


    if effect.has_method("set_params"):
        effect.set_params(params)


    if effect.has_signal("effect_finished"):
        effect.effect_finished.connect(_on_effect_finished.bind(effect))


    if effect.has_method("on_spawn"):
        effect.on_spawn()

    print("[EffectManager] 生成特效: " + type_name)

    return effect




func recycle(effect: Node) -> void :
    if effect == null:
        return

    if effect in _active_effects:
        _active_effects.erase(effect)


    if effect.has_signal("effect_finished"):
        if effect.effect_finished.is_connected(_on_effect_finished):
            effect.effect_finished.disconnect(_on_effect_finished)


    if effect.has_method("on_despawn"):
        effect.on_despawn()


    effect.get_parent().remove_child(effect)
    effect.queue_free()

    print("[EffectManager] 回收特效")



func recycle_all() -> void :
    for effect in _active_effects.duplicate():
        recycle(effect)



func get_active_count() -> int:
    return _active_effects.size()




func _on_effect_finished(effect: Node) -> void :
    recycle(effect)
