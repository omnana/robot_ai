extends Node


var _game_entry: IGameEntry = null

func _ready() -> void :

    ConfigManager.apply_settings()


    await get_tree().process_frame


    _load_game_entry()


    if _game_entry:
        _game_entry.on_framework_ready()

func _load_game_entry() -> void :
    var entry_path: = "res://game/game_entry.gd"
    if ResourceLoader.exists(entry_path):
        var script: = load(entry_path)
        if script:
            _game_entry = script.new()
