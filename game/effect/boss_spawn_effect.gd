class_name BossSpawnEffect
extends Node2D





signal effect_finished


@export var warning_duration: float = 2.0


@export var blink_speed: float = 0.2


var boss: Node2D = null


var _warning_sprite: Sprite2D = null


var _timer: float = 0.0


var _blink_timer: float = 0.0


var _is_blinking: bool = false


var _initialized: bool = false


func _ready() -> void :
    _warning_sprite = $WarningSprite
    _warning_sprite.z_index = LayerConstants.Z_WARNING_EFFECT
    _warning_sprite.z_as_relative = false
    _initialized = true


func _process(delta: float) -> void :
    if not _is_blinking:
        return

    _timer += delta
    _blink_timer += delta


    _update_blink()


    if _timer >= warning_duration:
        _is_blinking = false
        _on_warning_finished()



func _update_blink() -> void :
    if _warning_sprite == null:
        return


    var blink_cycle = fmod(_blink_timer, blink_speed * 2)
    var alpha = 0.3 + 0.7 * (0.5 + 0.5 * cos(blink_cycle * PI / blink_speed))


    var remaining_time = warning_duration - _timer
    if remaining_time < 0.5:
        var fast_blink = fmod(_blink_timer, 0.1 * 2)
        alpha = 0.3 + 0.7 * (0.5 + 0.5 * cos(fast_blink * PI / 0.1))

    _warning_sprite.modulate.a = alpha



func on_spawn() -> void :
    if _warning_sprite == null:
        await ready

    _timer = 0.0
    _blink_timer = 0.0
    _is_blinking = true
    _initialized = true


    _warning_sprite.visible = true
    _warning_sprite.modulate.a = 1.0



func on_despawn() -> void :
    _is_blinking = false
    _timer = 0.0
    _blink_timer = 0.0



func set_params(params: Dictionary) -> void :
    if _warning_sprite == null:
        await ready

    if params.has("position"):
        global_position = params["position"]

    if params.has("boss"):
        boss = params["boss"]

    if params.has("warning_duration"):
        warning_duration = params["warning_duration"]

    if params.has("blink_speed"):
        blink_speed = params["blink_speed"]



func _on_warning_finished() -> void :
    print("[BossSpawnEffect] 警告结束")


    if _warning_sprite != null:
        _warning_sprite.visible = false


    effect_finished.emit()


    if boss != null and boss.has_method("start_battle"):
        print("[BossSpawnEffect] 调用 boss.start_battle()")
        boss.start_battle()
