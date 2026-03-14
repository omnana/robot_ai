class_name IEffect
extends RefCounted


signal effect_finished(effect: IEffect)


func on_spawn() -> void :
    pass


func on_update(delta: float) -> void :
    pass


func on_despawn() -> void :
    pass


func set_params(params: Dictionary) -> void :
    pass
