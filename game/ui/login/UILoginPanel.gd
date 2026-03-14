extends UIPanel


@onready var login_button: TextureButton = $VBoxContainer / LoginButton
@onready var exit_button: TextureButton = $VBoxContainer / ExitButton

func _ready() -> void :
    login_button.pressed.connect(_on_login_button_pressed)
    exit_button.pressed.connect(_on_exit_button_pressed)

func _on_login_button_pressed() -> void :
    UIManager.close_all()
    UIManager.open(UIKeys.MENU_PANEL())

func _on_exit_button_pressed() -> void :
    get_tree().quit()
