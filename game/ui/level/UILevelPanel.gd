extends UIPanel

@onready var exit_button: TextureButton = $ExitButton
@onready var left_button: TextureButton = $LeftButton
@onready var right_button: TextureButton = $RightButton
@onready var lock_icon: TextureRect = $CenterContainer / VBoxContainer / LevelIconContainer / LevelIcon / LockIcon
@onready var level_icon: TextureButton = $CenterContainer / VBoxContainer / LevelIconContainer / LevelIcon
@onready var level_name_label: Label = $CenterContainer / VBoxContainer / LevelNameLabel

signal level_entered(level_id: int)

var _current_level_index: int = 0
var _levels: Array[Dictionary] = []

func _ready() -> void :
    exit_button.pressed.connect(_on_exit_pressed)
    left_button.pressed.connect(_on_left_pressed)
    right_button.pressed.connect(_on_right_pressed)
    level_icon.pressed.connect(_on_level_icon_pressed)

    _levels = LevelManager.get_all_levels()
    _update_display()

func _update_display() -> void :
    if _levels.is_empty():
        return

    var level = _levels[_current_level_index]
    var level_id = level.get("id", 0)
    var is_unlocked = LevelManager.is_level_unlocked(level_id)

    var icon_path = level.get("icon", "")
    if icon_path != "":
        var icon = AssetManager.load(icon_path)
        if icon != null:
            level_icon.texture_normal = icon

    level_name_label.text = level.get("name", "")

    if is_unlocked:
        lock_icon.visible = false
        level_icon.modulate = Color.WHITE
    else:
        lock_icon.visible = true
        level_icon.modulate = Color(0.5, 0.5, 0.5, 1.0)

    left_button.visible = _current_level_index > 0
    right_button.visible = _current_level_index < _levels.size() - 1

func _on_left_pressed() -> void :
    if _current_level_index > 0:
        _current_level_index -= 1
        _update_display()

func _on_right_pressed() -> void :
    if _current_level_index < _levels.size() - 1:
        _current_level_index += 1
        _update_display()

func _on_level_icon_pressed() -> void :
    var level = _levels[_current_level_index]
    var level_id = level.get("id", 0)
    var map_scene_path = level.get("map_scene_path", "")

    if LevelManager.is_level_unlocked(level_id):
        LevelManager.set_current_level(level_id)
        UIManager.close_all()
        if map_scene_path != "" and ResourceLoader.exists(map_scene_path):
            SceneNavigator.goto_scene_by_path(map_scene_path)
        else:
            UIToast.show_message("地图场景未配置", 1.0)
    else:
        UIToast.show_message("关卡还未解锁", 1.0)

func _on_exit_pressed() -> void :
    UIManager.close_all()
    UIManager.open(UIKeys.MENU_PANEL())
