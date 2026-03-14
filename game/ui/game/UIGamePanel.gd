extends UIPanel


@onready var exit_button: TextureButton = $ExitButton
@onready var boss_health_bar: Control = $BossHealthBarContainer / BossHealthBar

var _current_boss: Node = null
var _connected_controllers: Array[Node] = []


func _ready() -> void :
    exit_button.pressed.connect(_on_exit_button_pressed)


func _process(_delta: float) -> void :
    _connect_battle_signals()


func _on_exit_button_pressed() -> void :

    UIManager.close_ui(UIKeys.EFFECT_PANEL())

    UIManager.close_all()

    SceneNavigator.goto_scene("entry", 0.5, func():
        UIManager.open(UIKeys.LEVEL_SELECT_PANEL())

        if not AudioManager.is_bgm_playing_path("res://resources/audios/music/bgm_menu.mp3"):
            AudioManager.play_bgm("res://resources/audios/music/bgm_menu.mp3")
    )


func _on_show(_data: Dictionary) -> void :
    pass


func _connect_battle_signals() -> void :
    var controllers = get_tree().get_nodes_in_group("boss_battle_controller")
    for controller in controllers:
        if controller in _connected_controllers:
            continue
        if controller.has_signal("battle_started"):
            if not controller.battle_started.is_connected(_on_battle_started):
                controller.battle_started.connect(_on_battle_started)
        if controller.has_signal("battle_ended"):
            if not controller.battle_ended.is_connected(_on_battle_ended):
                controller.battle_ended.connect(_on_battle_ended)
        _connected_controllers.append(controller)


func _on_battle_started(boss: Node) -> void :
    if boss == null:
        return

    _current_boss = boss


    var boss_name_text = _get_boss_name(boss)
    var current_hp = _get_boss_hp(boss)
    var max_hp = _get_boss_max_hp(boss)

    print("[UIGamePanel] _on_battle_started called, boss: ", boss, " name: ", boss_name_text, " hp: ", current_hp, "/", max_hp)


    if boss_health_bar:
        boss_health_bar.show_boss(boss_name_text, current_hp, max_hp)
        print("[UIGamePanel] 显示Boss血量条: ", boss_name_text, current_hp, "/", max_hp)
    else:
        push_warning("[UIGamePanel] boss_health_bar is null")


    if boss.has_signal("hp_changed"):
        if not boss.hp_changed.is_connected(_on_boss_hp_changed):
            boss.hp_changed.connect(_on_boss_hp_changed)


func _on_battle_ended(_victory: bool) -> void :

    if boss_health_bar:
        boss_health_bar.hide_boss()


    if _current_boss and _current_boss.has_signal("hp_changed"):
        if _current_boss.hp_changed.is_connected(_on_boss_hp_changed):
            _current_boss.hp_changed.disconnect(_on_boss_hp_changed)

    _current_boss = null


func _on_boss_hp_changed(current: int, maximum: int) -> void :
    if boss_health_bar:
        boss_health_bar.update_hp(current, maximum)


func _get_boss_name(boss: Node) -> String:
    if "character_name" in boss:
        return boss.character_name
    return "Boss"


func _get_boss_hp(boss: Node) -> int:
    if "current_hp" in boss:
        return boss.current_hp
    return 100


func _get_boss_max_hp(boss: Node) -> int:
    if "max_hp" in boss:
        return boss.max_hp
    return 100
