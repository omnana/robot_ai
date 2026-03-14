class_name DamageNumber
extends Node2D





signal effect_finished


@export var value: int = -10


@export var text_color: Color = Color.RED


@export var font_size: int = 50


@export var duration: float = 1.0


@export var float_distance: float = 60.0


@export var random_offset_range: float = 30.0


var _label: Label = null


var _timer: float = 0.0


var _start_position: Vector2 = Vector2.ZERO


var _random_offset: float = 0.0


var _initialized: bool = false


func _ready() -> void :
    _label = $Label
    z_index = LayerConstants.Z_UI

    _start_position = global_position


func _process(delta: float) -> void :
    if not _initialized:
        return

    _timer += delta

    if _timer >= duration:
        effect_finished.emit()
        return

    _update_animation()



func _setup_initial_state() -> void :
    if _label == null:
        return

    _label.scale = Vector2(0.5, 0.5)
    _label.modulate.a = 1.0
    _label.modulate = text_color
    _update_label_text()



func on_spawn() -> void :
    if _label == null:
        await ready


    _start_position = global_position
    _random_offset = randf_range( - random_offset_range, random_offset_range)
    _timer = 0.0
    _initialized = true

    _setup_initial_state()



func on_despawn() -> void :
    _timer = 0.0
    _initialized = false



func set_params(params: Dictionary) -> void :
    if _label == null:
        await ready

    if params.has("value"):
        value = params["value"]
        _update_label_text()

    if params.has("color"):
        text_color = params["color"]
        if _label != null:
            _label.modulate = text_color

    if params.has("font_size"):
        font_size = params["font_size"]
        if _label != null:
            _label.add_theme_font_size_override("font_size", font_size)

    if params.has("z_index"):
        z_index = params["z_index"]



func _update_label_text() -> void :
    if _label == null:
        return

    if value >= 0:
        _label.text = "+" + str(value)
    else:
        _label.text = str(value)



func _update_animation() -> void :
    if _label == null:
        return

    var t = _timer / duration







    var y_offset = - float_distance * t
    global_position = _start_position + Vector2(_random_offset, y_offset)


    if t > 0.7:
        var fade_t = (t - 0.7) / 0.3
        _label.modulate.a = 1.0 - fade_t



func _ease_out_back(t: float) -> float:
    const c1 = 1.70158
    const c3 = c1 + 1
    if t < 0.5:
        return 0.5 * (1 + c3 * pow(2 * t - 1, 3) + c1 * pow(2 * t - 1, 2))
    else:
        return 0.5 * (2 - (1 + c3 * pow(-2 * t + 2, 3) + c1 * pow(-2 * t + 2, 2)))
