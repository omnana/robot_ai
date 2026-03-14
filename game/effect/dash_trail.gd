class_name DashTrail
extends Area2D





signal effect_finished


@export var damage: int = 10


@export var duration: float = 3.0


@export var collision_size: Vector2 = Vector2(40, 40)


@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


var _timer: float = 0.0


var _has_damaged: bool = false


func _ready() -> void :

    if _collision_shape != null and _collision_shape.shape != null:
        _collision_shape.shape.size = collision_size


    body_entered.connect(_on_body_entered)


func _process(delta: float) -> void :
    if _timer <= 0:
        return

    _timer -= delta


    if _timer <= 0:
        effect_finished.emit()



func on_spawn() -> void :
    _timer = duration
    _has_damaged = false



func on_despawn() -> void :
    _has_damaged = false



func set_params(params: Dictionary) -> void :
    if params.has("duration"):
        duration = params["duration"]

    if params.has("damage"):
        damage = params["damage"]

    if params.has("z_index"):
        z_index = params["z_index"]

    if params.has("collision_size"):
        collision_size = params["collision_size"]
        if _collision_shape != null and _collision_shape.shape != null:
            _collision_shape.shape.size = collision_size



func _on_body_entered(body: Node2D) -> void :

    if body is Player and not _has_damaged:
        _has_damaged = true
        _apply_damage_to_player(body)



func _apply_damage_to_player(player: Player) -> void :
    if player.has_method("take_damage"):
        player.take_damage(damage)
        print("[DashTrail] 对玩家造成伤害: " + str(damage))
