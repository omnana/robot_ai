class_name BuffManager
extends Node


signal buff_gained(buff_id: String, buff_name: String, buff_desc: String)


enum BuffType {
	HOMING_BULLET,
	TRIPLE_SHOT,
	RAPID_FIRE,
	LIFE_STEAL,
	PHANTOM_DODGE,
}


const BUFF_DATA: Dictionary = {
	BuffType.HOMING_BULLET: {
		"id": "homing_bullet",
		"name": "追踪弹",
		"desc": "子弹自动追踪最近的敌人",
		"icon": "🎯",
	},
	BuffType.TRIPLE_SHOT: {
		"id": "triple_shot",
		"name": "三连发",
		"desc": "每次射击发射3颗扇形子弹",
		"icon": "🔱",
	},
	BuffType.RAPID_FIRE: {
		"id": "rapid_fire",
		"name": "急速射击",
		"desc": "攻击速度提升50%",
		"icon": "⚡",
	},
	BuffType.LIFE_STEAL: {
		"id": "life_steal",
		"name": "生命汲取",
		"desc": "命中敌人回复2点HP",
		"icon": "💚",
	},
	BuffType.PHANTOM_DODGE: {
		"id": "phantom_dodge",
		"name": "幻影闪避",
		"desc": "闪避冷却减半，距离翻倍",
		"icon": "💨",
	},
}


var active_buffs: Array[int] = []
var _available_buffs: Array[int] = []
var _player: Node = null
var _ui_label: Label = null


func _ready() -> void:
	_reset_available_buffs()


func setup(player: Node) -> void:
	_player = player
	_create_buff_ui()


func _reset_available_buffs() -> void:
	_available_buffs = [
		BuffType.HOMING_BULLET,
		BuffType.TRIPLE_SHOT,
		BuffType.RAPID_FIRE,
		BuffType.LIFE_STEAL,
		BuffType.PHANTOM_DODGE,
	]


func grant_random_buff() -> void:
	if _available_buffs.is_empty():
		print("[BuffManager] 所有Buff已获取")
		return

	var index = randi() % _available_buffs.size()
	var buff_type = _available_buffs[index]
	_available_buffs.remove_at(index)

	_apply_buff(buff_type)


func _apply_buff(buff_type: int) -> void:
	if buff_type in active_buffs:
		return

	active_buffs.append(buff_type)
	var data = BUFF_DATA[buff_type]
	print("[BuffManager] 获得Buff: ", data["name"], " - ", data["desc"])

	match buff_type:
		BuffType.RAPID_FIRE:
			_apply_rapid_fire()
		BuffType.PHANTOM_DODGE:
			_apply_phantom_dodge()

	buff_gained.emit(data["id"], data["name"], data["desc"])
	_update_buff_ui()


func _apply_rapid_fire() -> void:
	if _player == null:
		return
	if _player.weapon != null:
		_player.weapon.attack_speed *= 1.5
		_player.weapon._update_fire_cooldown()
		print("[BuffManager] 急速射击: 攻速 x1.5")


func _apply_phantom_dodge() -> void:
	if _player == null:
		return
	_player.dodge_cooldown /= 2.0
	_player.dodge_distance *= 2.0
	print("[BuffManager] 幻影闪避: 冷却减半, 距离翻倍")


func has_buff(buff_type: int) -> bool:
	return buff_type in active_buffs


func _create_buff_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "BuffUILayer"
	canvas.layer = 10
	add_child(canvas)

	_ui_label = Label.new()
	_ui_label.name = "BuffLabel"
	_ui_label.position = Vector2(20, 20)
	_ui_label.add_theme_font_size_override("font_size", 20)
	_ui_label.add_theme_color_override("font_color", Color.WHITE)
	_ui_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_ui_label.add_theme_constant_override("shadow_offset_x", 2)
	_ui_label.add_theme_constant_override("shadow_offset_y", 2)
	_ui_label.text = ""
	canvas.add_child(_ui_label)


func _update_buff_ui() -> void:
	if _ui_label == null:
		return

	var lines: Array[String] = []
	for buff_type in active_buffs:
		var data = BUFF_DATA[buff_type]
		lines.append(data["icon"] + " " + data["name"] + " - " + data["desc"])

	_ui_label.text = "\n".join(lines)
