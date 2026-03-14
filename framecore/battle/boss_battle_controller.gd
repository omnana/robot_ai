

class_name BossBattleController
extends Node


signal battle_started(boss: Node)

signal battle_ended(victory: bool)


@export var boss_scene: PackedScene

@export var arena_size: Vector2 = Vector2(1200, 800)

@export var camera_zoom_out: float = 0.5

@export var intro_duration: float = 2.0


var _arena: BattleArena = null

var _boss_instance: Node = null

var _player: CharacterBody2D = null

var _player_camera: Camera2D = null

var _original_camera_zoom: Vector2 = Vector2.ONE

var _is_battling: bool = false

var _intro_tween: Tween = null


func _ready() -> void :

    add_to_group("boss_battle_controller")


    _arena = BattleArena.new()
    _arena.name = "BattleArena"
    _arena.arena_size = arena_size
    add_child(_arena)


    _arena.arena_created.connect(_on_arena_created)
    _arena.arena_destroyed.connect(_on_arena_destroyed)





func start_battle(player: CharacterBody2D, spawn_position: Vector2) -> void :
    if _is_battling:
        push_warning("BossBattleController: 战斗已在进行中")
        return

    if boss_scene == null:
        push_error("BossBattleController: Boss预制体未设置")
        return

    if player == null:
        push_error("BossBattleController: 玩家为空")
        return

    _is_battling = true
    _player = player


    _player_camera = _get_player_camera()
    if _player_camera == null:
        push_warning("BossBattleController: 未找到玩家摄像机")


    _lock_player()


    _zoom_out_camera()


    _arena.create_arena(spawn_position)




func end_battle(victory: bool) -> void :
    if not _is_battling:
        push_warning("BossBattleController: 战斗未开始")
        return

    _is_battling = false


    if _intro_tween and _intro_tween.is_valid():
        _intro_tween.kill()
        _intro_tween = null


    if not victory and _boss_instance and is_instance_valid(_boss_instance):
        _boss_instance.queue_free()
        _boss_instance = null


    _unlock_player()


    if _player_camera:
        _arena.unlock_camera()
        _reset_camera_zoom()


    _arena.destroy_arena()


    if victory:
        print("[BossBattleController] ========== 战斗胜利 ==========")
    else:
        print("[BossBattleController] ========== 战斗失败 ==========")


    battle_ended.emit(victory)



func _lock_player() -> void :
    if _player == null:
        return


    _player.set_process(false)
    _player.set_physics_process(false)


    if _player.has_method("set_locked"):
        _player.call("set_locked", true)



func _unlock_player() -> void :
    if _player == null:
        return


    _player.set_process(true)
    _player.set_physics_process(true)


    if _player.has_method("set_locked"):
        _player.call("set_locked", false)



func _get_player_camera() -> Camera2D:
    if _player == null:
        return null


    for child in _player.get_children():
        if child is Camera2D:
            return child

    return null



func _zoom_out_camera() -> void :
    if _player_camera == null:
        return


    _original_camera_zoom = _player_camera.zoom


    if _intro_tween and _intro_tween.is_valid():
        _intro_tween.kill()

    _intro_tween = create_tween()
    _intro_tween.set_ease(Tween.EASE_OUT)
    _intro_tween.set_trans(Tween.TRANS_QUAD)

    var target_zoom = _original_camera_zoom * (1.0 - camera_zoom_out)
    _intro_tween.tween_property(_player_camera, "zoom", target_zoom, intro_duration * 0.3)



func _reset_camera_zoom() -> void :
    if _player_camera == null:
        return


    var reset_tween = create_tween()
    reset_tween.set_ease(Tween.EASE_OUT)
    reset_tween.set_trans(Tween.TRANS_QUAD)
    reset_tween.tween_property(_player_camera, "zoom", _original_camera_zoom, 0.5)



func _on_arena_created() -> void :

    if _player_camera:
        _arena.lock_camera(_player_camera)


    _spawn_boss()



func _on_arena_destroyed() -> void :
    pass



func _spawn_boss() -> void :
    if boss_scene == null:
        push_error("BossBattleController: Boss预制体为空")
        end_battle(false)
        return


    _boss_instance = boss_scene.instantiate()
    _boss_instance.name = "Boss"


    if _boss_instance.has_signal("died"):
        _boss_instance.died.connect(_on_boss_died)


    var bounds = _arena.get_bounds()


    var spawn_position = Vector2(
        bounds.get_center().x, 
        bounds.position.y + 100
    )

    _boss_instance.position = spawn_position


    LayerManager.add_character(_boss_instance)


    if _boss_instance.has_method("init_from_config"):
        _boss_instance.call("init_from_config", "angry_bull")

    if _boss_instance.has_method("set_target") and _player != null:
        _boss_instance.call("set_target", _player)


    _boss_intro_animation()



func _boss_intro_animation() -> void :
    if _boss_instance == null:
        _finish_intro()
        return


    _spawn_boss_with_effect()



func _spawn_boss_with_effect() -> void :
    if _boss_instance == null:
        _finish_intro()
        return


    var effect = EffectManager.spawn("boss_spawn", {
        "position": _boss_instance.global_position, 
        "boss": _boss_instance, 
        "warning_duration": 2.0, 
        "blink_speed": 0.2
    })


    if effect and effect.has_signal("effect_finished"):
        effect.effect_finished.connect(_on_spawn_effect_finished)



func _finish_intro() -> void :

    _unlock_player()


    battle_started.emit(_boss_instance)



func _on_spawn_effect_finished() -> void :
    _finish_intro()



func _on_boss_died() -> void :
    print("[BossBattleController] 收到Boss死亡信号")


    var death_delay = 2.0


    var timer = get_tree().create_timer(death_delay)
    timer.timeout.connect( func(): end_battle(true))
