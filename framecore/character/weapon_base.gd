class_name WeaponBase
extends Node2D



signal fired()


@export var attack_speed: float = 1.0


@export var damage: int = 1


var _last_fire_time: float = 0.0


var _fire_cooldown: float = 0.0


func _ready() -> void :
    _update_fire_cooldown()



func _update_fire_cooldown() -> void :
    if attack_speed > 0:
        _fire_cooldown = 1.0 / attack_speed
    else:
        _fire_cooldown = 0.0



func can_fire() -> bool:
    var current_time: float = Time.get_ticks_msec() / 1000.0
    return current_time - _last_fire_time >= _fire_cooldown



func try_fire() -> bool:
    if not can_fire():
        return false
    _do_fire()
    _last_fire_time = Time.get_ticks_msec() / 1000.0
    fired.emit()
    return true



func _do_fire() -> void :
    push_warning("WeaponBase._do_fire() should be overridden")



func set_attack_speed(speed: float) -> void :
    attack_speed = speed
    _update_fire_cooldown()
