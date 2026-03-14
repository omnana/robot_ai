






class_name Boss
extends Character



signal phase_changed(phase: int)



var boss_id: String = ""
var target: Node2D = null
var is_enraged: bool = false
var current_phase: int = 1
var state_chart: Node = null

var phase2_hp_threshold: int = 50
var phase2_speed_multiplier: float = 1.5
var phase2_telegraph_multiplier: float = 0.5
var dash_speed: float = 800.0
var telegraph_time: float = 1.0
var stun_time: float = 0.5
var damage: int = 20
var bounce_count: int = 3
var trail_duration: float = 3.0
var bullet_count: int = 8


var _health_bar: HealthBar = null



func init_from_config(id: String) -> void :
    boss_id = id

    var config = _get_config_by_string_id("bosses", id)

    if config.is_empty():
        push_warning("[Boss] 配置不存在，使用默认属性: id=" + id)
        _apply_default_values()
        return

    _apply_config(config)

    print("[Boss] 加载配置成功: id=" + id)


func _get_config_by_string_id(table_name: String, id: String) -> Dictionary:
    var data = TableData.get_all(table_name)

    for row in data:
        if row.get("id") == id:
            return row

    return {}


func _apply_config(config: Dictionary) -> void :
    super._apply_config(config)

    if config.has("dash_speed"):
        dash_speed = config["dash_speed"]

    if config.has("telegraph_time"):
        telegraph_time = config["telegraph_time"]

    if config.has("stun_time"):
        stun_time = config["stun_time"]

    if config.has("damage"):
        damage = config["damage"]

    if config.has("phase2_hp_threshold"):
        phase2_hp_threshold = config["phase2_hp_threshold"]

    if config.has("phase2_speed_multiplier"):
        phase2_speed_multiplier = config["phase2_speed_multiplier"]

    if config.has("phase2_telegraph_multiplier"):
        phase2_telegraph_multiplier = config["phase2_telegraph_multiplier"]

    if config.has("bounce_count"):
        bounce_count = config["bounce_count"]

    if config.has("trail_duration"):
        trail_duration = config["trail_duration"]

    if config.has("bullet_count"):
        bullet_count = config["bullet_count"]


func _apply_default_values() -> void :
    super._apply_default_values()
    dash_speed = 800.0
    telegraph_time = 1.0
    stun_time = 0.5
    damage = 20
    phase2_hp_threshold = 50
    phase2_speed_multiplier = 1.5
    phase2_telegraph_multiplier = 0.5
    bounce_count = 3
    trail_duration = 3.0
    bullet_count = 8


func _setup_state_chart() -> void :
    for child in get_children():
        if child.get_script() != null and child.get_script().get_path().contains("state_chart"):
            state_chart = child
            print("[Boss] 找到状态机: " + child.name)
            return

    if state_chart == null:
        push_warning("[Boss] 未找到 StateChart 子节点，请在场景中添加状态机")



func _setup_health_bar() -> void :
    _health_bar = HealthBar.new()
    _health_bar.bar_width = 80.0
    _health_bar.bar_height = 8.0
    _health_bar.bar_offset = Vector2(0, -80)
    add_child(_health_bar)



func take_damage(amount: int) -> void :
    current_hp = max(0, current_hp - amount)

    hp_changed.emit(current_hp, max_hp)



    if current_hp <= 0:
        die()
        return

    _check_phase_transition()













func _check_phase_transition() -> void :
    var hp_percent = (current_hp as float / max_hp as float) * 100

    if current_phase == 1 and hp_percent <= phase2_hp_threshold:
        _enter_phase_2()


func _enter_phase_2() -> void :
    current_phase = 2
    is_enraged = true

    move_speed *= phase2_speed_multiplier
    telegraph_time *= phase2_telegraph_multiplier

    phase_changed.emit(current_phase)

    if state_chart != null:
        state_chart.send_event(&"enrage")

    print("[Boss] 进入阶段2（狂暴模式）: " + boss_id)


func die() -> void :
    died.emit()

    if state_chart != null:
        state_chart.send_event(&"die")

    print("[Boss] Boss死亡: " + boss_id)



func set_target(new_target: Node2D) -> void :
    target = new_target


func get_direction_to_target() -> Vector2:
    if target == null or not is_instance_valid(target):
        return Vector2.ZERO
    return (target.global_position - global_position).normalized()


func get_distance_to_target() -> float:
    if target == null or not is_instance_valid(target):
        return -1.0
    return global_position.distance_to(target.global_position)



func _update_health_bar_position() -> void :
    if _health_bar:
        _health_bar.update_position(global_position)



func _on_hp_changed(current: int, maximum: int) -> void :


    pass



func _ready() -> void :
    super._ready()

    add_to_group("enemy")

    collision_layer = LayerConstants.COLLISION_ENEMY
    collision_mask = LayerConstants.COLLISION_OBSTACLE

    _setup_state_chart()


    hp_changed.connect(_on_hp_changed)

    if has_method("_connect_state_signals"):
        call("_connect_state_signals")


func _physics_process(delta: float) -> void :
    super._physics_process(delta)
