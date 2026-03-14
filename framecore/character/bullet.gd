class_name Bullet
extends Area2D




signal request_recycle


@export var speed: float = 800.0


@export var damage: int = 1


@export var safe_margin: float = 100.0


var direction: Vector2 = Vector2.UP


var source: String = ""


var is_homing: bool = false

var homing_turn_speed: float = 4.0

var _homing_target: Node2D = null

var owner_node: Node = null


@onready var sprite: Sprite2D = $Sprite2D


@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


var _has_left_screen: bool = false


func _ready() -> void :
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

    if visibility_notifier:
        visibility_notifier.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float) -> void :
    if is_homing:
        _update_homing(delta)

    position += direction * speed * delta

    if _has_left_screen:
        _check_safe_margin_recycle()



func reset_state() -> void :
    direction = Vector2.UP
    _has_left_screen = false
    is_homing = false
    _homing_target = null
    owner_node = null



func on_acquired_from_pool() -> void :
    _has_left_screen = false



func on_returned_to_pool() -> void :
    _has_left_screen = false



func set_direction(dir: Vector2) -> void :
    direction = dir.normalized()
    rotation = direction.angle()



func set_initial_position(pos: Vector2) -> void :
    global_position = pos



func _on_body_entered(body: Node2D) -> void :
    _apply_damage(body)
    _spawn_hit_effect()
    _request_recycle()



func _on_area_entered(area: Area2D) -> void :
    _apply_damage(area)
    _spawn_hit_effect()
    _request_recycle()



func _apply_damage(target: Node) -> void :
    if target.has_method("take_damage"):
        target.take_damage(damage)

    # 生命汲取
    if source == "player" and owner_node != null and is_instance_valid(owner_node):
        if owner_node.has_method("_on_bullet_hit_enemy"):
            owner_node._on_bullet_hit_enemy()



func _spawn_hit_effect() -> void :
    EffectManager.spawn("hit_effect", {
        "position": global_position, 
        "scale": Vector2.ONE * 0.5
    })


    if source == "player":
        AudioManager.play_se("res://resources/audios/sfx/effect_bullet.mp3")



func _on_screen_exited() -> void :
    _has_left_screen = true



func _check_safe_margin_recycle() -> void :
    var viewport_rect: Rect2 = get_viewport_rect()
    var camera: Camera2D = get_viewport().get_camera_2d()

    if camera:
        var camera_pos: Vector2 = camera.global_position
        var half_size: Vector2 = viewport_rect.size / 2
        var expanded_rect: Rect2 = Rect2(
            camera_pos - half_size - Vector2(safe_margin, safe_margin), 
            viewport_rect.size + Vector2(safe_margin * 2, safe_margin * 2)
        )

        if not expanded_rect.has_point(global_position):
            _request_recycle()
    else:
        var expanded_rect: Rect2 = viewport_rect.grow(safe_margin)
        if not expanded_rect.has_point(global_position):
            _request_recycle()



func _request_recycle() -> void :
    request_recycle.emit()


func _update_homing(delta: float) -> void :
    if _homing_target == null or not is_instance_valid(_homing_target):
        _homing_target = _find_nearest_enemy()
        if _homing_target == null:
            return

    var desired_dir = ((_homing_target.global_position - global_position)).normalized()
    var current_angle = direction.angle()
    var target_angle = desired_dir.angle()
    var new_angle = lerp_angle(current_angle, target_angle, homing_turn_speed * delta)
    direction = Vector2.from_angle(new_angle)
    rotation = new_angle


func _find_nearest_enemy() -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemy")
    var nearest: Node2D = null
    var min_dist: float = 9999999.0
    for enemy in enemies:
        if not is_instance_valid(enemy) or not enemy is Node2D:
            continue
        # 跳过已死亡的敌人
        if enemy is CharacterBody2D and enemy.get("current_hp") != null and enemy.current_hp <= 0:
            continue
        var dist = global_position.distance_to(enemy.global_position)
        if dist < min_dist:
            min_dist = dist
            nearest = enemy
    return nearest
