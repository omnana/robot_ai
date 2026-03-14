class_name PlayerDashTrail
extends Sprite2D





@export var duration: float = 0.3


@export var initial_alpha: float = 0.5


var _timer: float = 0.0


func _ready() -> void :
    modulate.a = initial_alpha


func _process(delta: float) -> void :
    if _timer <= 0:
        return

    _timer -= delta

    modulate.a = initial_alpha * (_timer / duration)

    if _timer <= 0:
        queue_free()



func on_spawn() -> void :
    _timer = duration
    modulate.a = initial_alpha



func set_params(params: Dictionary) -> void :
    if params.has("duration"):
        duration = params["duration"]

    if params.has("initial_alpha"):
        initial_alpha = params["initial_alpha"]

    if params.has("texture"):
        texture = params["texture"]

    if params.has("flip_h"):
        flip_h = params["flip_h"]

    if params.has("scale"):
        scale = params["scale"]
