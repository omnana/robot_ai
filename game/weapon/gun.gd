class_name Gun
extends WeaponBase



@export var bullet_manager: BulletManager


@export var bullet_speed: float = 800.0


@export var recoil_strength: float = 10.0


@export var recoil_recovery_speed: float = 20.0


@onready var muzzle: Marker2D = $Muzzle


@onready var sprite: Sprite2D = $Sprite2D


var _recoil_offset: float = 0.0

func _process(delta: float) -> void :
    _rotate_to_mouse()
    _update_recoil(delta)



func _rotate_to_mouse() -> void :
    var mouse_position: Vector2 = get_global_mouse_position()
    var target_angle: float = (mouse_position - global_position).angle()

    rotation = target_angle


    if sprite:
        var is_facing_left: bool = abs(target_angle) > PI / 2
        sprite.flip_v = is_facing_left



func _update_recoil(delta: float) -> void :
    if _recoil_offset > 0:
        _recoil_offset = max(0, _recoil_offset - recoil_recovery_speed * delta)
        _apply_recoil()



func _apply_recoil() -> void :
    if sprite:
        sprite.position.x = - _recoil_offset



var _buff_manager: BuffManager = null


func set_buff_manager(manager: BuffManager) -> void:
    _buff_manager = manager


func _do_fire() -> void :
    if bullet_manager == null:
        push_warning("Gun: BulletManager is not assigned")
        return

    var muzzle_position: Vector2
    var direction: Vector2

    if muzzle:
        muzzle_position = muzzle.global_position
        direction = Vector2(cos(rotation), sin(rotation))
    else:
        muzzle_position = global_position + Vector2(cos(rotation), sin(rotation)) * 30.0
        direction = Vector2(cos(rotation), sin(rotation))

    var has_homing = _buff_manager != null and _buff_manager.has_buff(BuffManager.BuffType.HOMING_BULLET)
    var has_triple = _buff_manager != null and _buff_manager.has_buff(BuffManager.BuffType.TRIPLE_SHOT)

    var directions: Array[Vector2] = [direction]
    if has_triple:
        directions.append(direction.rotated(deg_to_rad(15)))
        directions.append(direction.rotated(deg_to_rad(-15)))

    var owner_ref = get_parent() if get_parent() is Character else null

    for dir in directions:
        var bullet: Bullet = bullet_manager.spawn_bullet(muzzle_position, dir, bullet_speed)
        if bullet:
            bullet.damage = damage
            bullet.source = "player"
            bullet.owner_node = owner_ref
            if has_homing:
                bullet.is_homing = true

    _apply_recoil_effect()
    AudioManager.play_se("res://resources/audios/sfx/effect_gun.mp3")



func _apply_recoil_effect() -> void :
    _recoil_offset = recoil_strength
    _apply_recoil()



func set_bullet_manager(manager: BulletManager) -> void :
    bullet_manager = manager
