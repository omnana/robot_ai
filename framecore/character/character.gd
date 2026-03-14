






class_name Character
extends CharacterBody2D



signal hp_changed(current_hp: int, max_hp: int)
signal died()



const DEFAULT_MAX_HP: int = 100
const DEFAULT_MOVE_SPEED: float = 200.0
const DEFAULT_ATTACK_POWER: int = 10
const DEFAULT_ATTACK_SPEED: float = 1.0
const DEFAULT_BULLET_SPEED: float = 400.0



var character_id: String = ""
var character_name: String = ""
var max_hp: int = DEFAULT_MAX_HP
var current_hp: int = DEFAULT_MAX_HP
var move_speed: float = DEFAULT_MOVE_SPEED
var attack_power: int = DEFAULT_ATTACK_POWER
var attack_speed: float = DEFAULT_ATTACK_SPEED
var bullet_speed: float = DEFAULT_BULLET_SPEED



func init_from_config(id: String) -> void :
    character_id = id

    var config = _get_config_by_string_id("characters", id)

    if config.is_empty():
        push_warning("[Character] 配置不存在，使用默认属性: id=" + id)
        _apply_default_values()
        return

    _apply_config(config)
    print("[Character] 加载配置成功: id=" + id)


func _get_config_by_string_id(table_name: String, id: String) -> Dictionary:
    var data = TableData.get_all(table_name)

    for row in data:
        if row.get("id") == id:
            return row

    return {}


func _apply_config(config: Dictionary) -> void :
    if config.has("name"):
        character_name = config["name"]

    if config.has("max_hp"):
        max_hp = config["max_hp"]
        current_hp = max_hp

    if config.has("move_speed"):
        move_speed = config["move_speed"]

    if config.has("attack_power"):
        attack_power = config["attack_power"]

    if config.has("attack_speed"):
        attack_speed = config["attack_speed"]

    if config.has("bullet_speed"):
        bullet_speed = config["bullet_speed"]


func _apply_default_values() -> void :
    max_hp = DEFAULT_MAX_HP
    current_hp = DEFAULT_MAX_HP
    move_speed = DEFAULT_MOVE_SPEED
    attack_power = DEFAULT_ATTACK_POWER
    attack_speed = DEFAULT_ATTACK_SPEED
    bullet_speed = DEFAULT_BULLET_SPEED





func take_damage(amount: int) -> void :
    current_hp = max(0, current_hp - amount)
    hp_changed.emit(current_hp, max_hp)

    print("[Character] 受到伤害: " + str(amount) + ", 剩余HP: " + str(current_hp))

    if current_hp <= 0:
        die()




func heal(amount: int) -> void :
    current_hp = min(max_hp, current_hp + amount)
    hp_changed.emit(current_hp, max_hp)

    print("[Character] 治疗: " + str(amount) + ", 当前HP: " + str(current_hp))



func die() -> void :
    died.emit()
    print("[Character] 角色死亡: " + character_id)



func _ready() -> void :
    pass


func _physics_process(_delta: float) -> void :
    move_and_slide()
