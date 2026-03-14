class_name HealthBar
extends Node2D





@export var bar_width: float = 60.0


@export var bar_height: float = 6.0


@export var bar_offset: Vector2 = Vector2(0, -60)


@export var full_color: Color = Color.GREEN


@export var mid_color: Color = Color.YELLOW


@export var low_color: Color = Color.RED


@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.8)


@export var border_color: Color = Color(0.1, 0.1, 0.1, 1.0)


@export var transition_duration: float = 0.2


var _current_percent: float = 1.0


var _target_percent: float = 1.0


var _transition_timer: float = 0.0


var _start_percent: float = 1.0


func _ready() -> void :
    z_index = LayerConstants.Z_UI
    top_level = true


func _process(delta: float) -> void :

    if _transition_timer > 0:
        _transition_timer -= delta
        var t = 1.0 - (_transition_timer / transition_duration)
        _current_percent = lerp(_start_percent, _target_percent, t)
        queue_redraw()





func set_hp(current: int, maximum: int) -> void :
    var new_percent = clamp(current as float / maximum as float, 0.0, 1.0)

    if new_percent != _target_percent:
        _start_percent = _current_percent
        _target_percent = new_percent
        _transition_timer = transition_duration
        queue_redraw()




func update_position(character_pos: Vector2) -> void :
    global_position = character_pos + bar_offset


func _draw() -> void :
    var half_width = bar_width / 2.0
    var half_height = bar_height / 2.0


    draw_rect(
        Rect2( - half_width - 1, - half_height - 1, bar_width + 2, bar_height + 2), 
        border_color
    )


    draw_rect(
        Rect2( - half_width, - half_height, bar_width, bar_height), 
        background_color
    )


    var fg_width = bar_width * _current_percent
    if fg_width > 0:
        var fg_color = _get_color_by_percent(_current_percent)
        draw_rect(
            Rect2( - half_width, - half_height, fg_width, bar_height), 
            fg_color
        )





func _get_color_by_percent(percent: float) -> Color:
    if percent > 0.6:
        return full_color
    elif percent > 0.3:
        return mid_color
    else:
        return low_color
