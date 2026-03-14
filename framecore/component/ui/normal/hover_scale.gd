class_name HoverScale extends Control



@export var hover_scale: float = 1.1
@export var hover_duration: float = 0.15

var _original_scale: Vector2 = Vector2.ONE
var _tween: Tween = null

func _ready() -> void :
    _original_scale = scale
    _update_pivot()
    resized.connect(_update_pivot)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _update_pivot() -> void :
    pivot_offset = size / 2.0

func _on_mouse_entered() -> void :
    _tween_scale(_original_scale * hover_scale)

func _on_mouse_exited() -> void :
    _tween_scale(_original_scale)

func _tween_scale(target_scale: Vector2) -> void :
    if _tween and _tween.is_valid():
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(self, "scale", target_scale, hover_duration).set_ease(Tween.EASE_OUT)
