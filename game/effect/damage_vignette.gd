class_name DamageVignette
extends CanvasLayer


@onready var color_rect: ColorRect = $ColorRect

var _tween: Tween = null
var _material: ShaderMaterial = null


func _ready() -> void :
    layer = 100
    _setup_material()
    _setup_color_rect()


func _setup_color_rect() -> void :
    if color_rect == null:
        return
    color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _setup_material() -> void :
    if color_rect == null:
        return

    _material = color_rect.material as ShaderMaterial
    if _material == null:
        return


    _set_intensity(0.0)


func _set_intensity(value: float) -> void :
    if _material == null:
        return

    _material.set_shader_parameter("intensity", value)





func show_damage(intensity: float = 0.5, duration: float = 0.3) -> void :
    if _material == null:
        return

    if _tween != null and _tween.is_valid():
        _tween.kill()

    _tween = create_tween()
    _tween.set_ease(Tween.EASE_OUT)


    _tween.tween_method(_set_intensity, 0.0, intensity, 0.08)

    _tween.tween_interval(0.1)

    _tween.tween_method(_set_intensity, intensity, 0.0, duration)



func hide_immediately() -> void :
    if _tween != null and _tween.is_valid():
        _tween.kill()

    _set_intensity(0.0)
