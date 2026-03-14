extends Node


func _ready() -> void :
    ConfigManager.apply_settings()
    GameState.set_state(GameState.State.MENU)
    EventBus.framework_ready.emit()
