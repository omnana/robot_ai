class_name UIProgressBar extends UIComponent


@export var bar_color: Color = Color(0.2, 0.6, 1.0)
@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.8)
@export var show_percentage: bool = true
@export var animation_duration: float = 0.3

var _current_ratio: float = 0.0
var _target_ratio: float = 0.0
var _tween: Tween

@onready var background: ColorRect = $Background
@onready var fill: ColorRect = $Fill
@onready var percentage_label: Label = $Label


func _on_init() -> void :
    visible = true
    _setup_style()
    _update_fill(_current_ratio)


func _setup_style() -> void :
    if background:
        background.color = background_color
    if fill:
        fill.color = bar_color
    if percentage_label:
        percentage_label.visible = show_percentage


func set_progress(value: float, max_value: float = 100.0) -> void :
    if max_value <= 0:
        return
    var ratio = clamp(value / max_value, 0.0, 1.0)
    _set_ratio(ratio)


func set_ratio(ratio: float) -> void :
    ratio = clamp(ratio, 0.0, 1.0)
    _set_ratio(ratio)


func get_ratio() -> float:
    return _current_ratio


func _set_ratio(ratio: float) -> void :
    _target_ratio = ratio
    _animate_to_target()


func _animate_to_target() -> void :
    if _tween and _tween.is_valid():
        _tween.kill()

    _tween = create_tween()
    _tween.set_ease(Tween.EASE_OUT)
    _tween.set_trans(Tween.TRANS_QUART)
    _tween.tween_method(_update_fill, _current_ratio, _target_ratio, animation_duration)


func _update_fill(ratio: float) -> void :
    _current_ratio = ratio

    if fill:
        fill.size.x = size.x * ratio

    if percentage_label and show_percentage:
        var percentage = int(ratio * 100)
        percentage_label.text = str(percentage) + "%"


func set_bar_color(color: Color) -> void :
    bar_color = color
    if fill:
        fill.color = bar_color


func set_background_color(color: Color) -> void :
    background_color = color
    if background:
        background.color = background_color


func set_show_percentage(is_show: bool) -> void :
    show_percentage = is_show
    if percentage_label:
        percentage_label.visible = show_percentage


func set_progress_immediate(value: float, max_value: float = 100.0) -> void :
    if max_value <= 0:
        return
    var ratio = clamp(value / max_value, 0.0, 1.0)
    _set_ratio_immediate(ratio)


func set_ratio_immediate(ratio: float) -> void :
    ratio = clamp(ratio, 0.0, 1.0)
    _set_ratio_immediate(ratio)


func _set_ratio_immediate(ratio: float) -> void :
    if _tween and _tween.is_valid():
        _tween.kill()

    _current_ratio = ratio
    _target_ratio = ratio
    _update_fill(ratio)
