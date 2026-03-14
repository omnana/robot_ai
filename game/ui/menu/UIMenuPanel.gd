extends UIPanel

@onready var level_button: TextureButton = $ButtonContainer / LevelButton
@onready var equip_button: TextureButton = $ButtonContainer / EquipButton
@onready var exit_button: TextureButton = $ButtonContainer / ExitButton

func _ready() -> void :
    level_button.pressed.connect(_on_level_button_pressed)
    equip_button.pressed.connect(_on_equip_button_pressed)
    exit_button.pressed.connect(_on_exit_button_pressed)

func _on_level_button_pressed() -> void :
    UIManager.close_all()
    UIManager.open(UIKeys.LEVEL_SELECT_PANEL())

func _on_equip_button_pressed() -> void :
    UIToast.show_message("装备功能开发中...", 1)

func _on_exit_button_pressed() -> void :
    UIManager.close_all()
    UIManager.open(UIKeys.LOGIN_PANEL())
