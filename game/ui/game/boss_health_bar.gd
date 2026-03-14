class_name BossHealthBar
extends Control



@export var bar_height: float = 24.0
@export var bar_width: float = 400.0
@export var name_label_width: float = 120.0
@export var padding: float = 8.0

@export var background_color: Color = Color(0.15, 0.15, 0.15, 0.9)
@export var border_color: Color = Color(0.8, 0.8, 0.8, 1.0)
@export var hp_color_high: Color = Color(0.2, 0.8, 0.2, 1.0)
@export var hp_color_mid: Color = Color(0.9, 0.8, 0.1, 1.0)
@export var hp_color_low: Color = Color(0.9, 0.2, 0.2, 1.0)
@export var name_color: Color = Color.WHITE

var boss_name: String = ""
var current_hp: int = 100
var max_hp: int = 100

var _display_hp: float = 100.0
var _target_hp: float = 100.0
var _hp_lerp_speed: float = 5.0


func _ready() -> void :
    visible = false
    _display_hp = float(max_hp)


func _process(delta: float) -> void :
    if abs(_display_hp - _target_hp) > 0.1:
        _display_hp = lerp(_display_hp, _target_hp, _hp_lerp_speed * delta)
        queue_redraw()


func show_boss(boss_name_text: String, hp: int, maximum: int) -> void :
    boss_name = boss_name_text
    current_hp = hp
    max_hp = maximum
    _display_hp = float(hp)
    _target_hp = float(hp)
    visible = true
    modulate.a = 0.0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 0.3)
    queue_redraw()


func update_hp(current: int, maximum: int) -> void :
    current_hp = current
    max_hp = maximum
    _target_hp = float(current)
    queue_redraw()


func hide_boss() -> void :
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.3)
    tween.tween_callback( func(): visible = false)


func _draw() -> void :
    var total_width = name_label_width + bar_width + padding * 3
    var start_x = - total_width / 2.0
    var start_y = - bar_height / 2.0

    var name_rect = Rect2(start_x, start_y, name_label_width, bar_height)
    var bar_rect = Rect2(start_x + name_label_width + padding, start_y, bar_width, bar_height)

    draw_rect(name_rect, background_color)
    draw_rect(name_rect.grow(2), border_color, false, 2.0)

    draw_rect(bar_rect, background_color)
    draw_rect(bar_rect.grow(2), border_color, false, 2.0)

    var font = ThemeDB.fallback_font
    var font_size = 16
    var name_pos = Vector2(
        name_rect.position.x + name_rect.size.x / 2.0, 
        name_rect.position.y + name_rect.size.y / 2.0 - font_size / 2.0
    )
    var name_text = boss_name if boss_name != "" else "Boss"
    draw_string(font, name_pos, name_text, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, name_rect.size.x, name_color)

    if max_hp > 0:
        var hp_percent = clamp(_display_hp / max_hp, 0.0, 1.0)
        var hp_bar_width = bar_width * hp_percent

        if hp_bar_width > 0:
            var hp_color = _get_hp_color(hp_percent)
            var hp_rect = Rect2(bar_rect.position.x, bar_rect.position.y, hp_bar_width, bar_rect.size.y)
            draw_rect(hp_rect, hp_color)

        var hp_text = "%d / %d" % [int(round(_display_hp)), max_hp]
        var hp_text_pos = Vector2(
            bar_rect.position.x + bar_rect.size.x / 2.0, 
            bar_rect.position.y + bar_rect.size.y / 2.0 - font_size / 2.0
        )
        draw_string(font, hp_text_pos, hp_text, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, bar_rect.size.x, Color.WHITE)


func _get_hp_color(percent: float) -> Color:
    if percent > 0.5:
        return hp_color_high
    elif percent > 0.25:
        return hp_color_mid
    else:
        return hp_color_low


func _get_minimum_size() -> Vector2:
    var total_width = name_label_width + bar_width + padding * 3
    return Vector2(total_width, bar_height + padding * 2)
