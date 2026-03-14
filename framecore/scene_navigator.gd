extends Node



signal scene_changed(scene_path: String)
signal scene_change_requested(scene_path: String)
signal load_progress(percent: int)
signal load_finished()

var _plugin: Node = null
var _pending_callback: Callable = Callable()

func _ready() -> void :
    await get_tree().process_frame
    _plugin = get_node_or_null("/root/scene_manager")
    if _plugin:
        _plugin.scene_changed.connect(_on_scene_changed)
        _plugin.load_percent_changed.connect(_on_load_percent_changed)
        _plugin.load_finished.connect(_on_load_finished)

func _on_scene_changed() -> void :
    scene_changed.emit(_plugin._current_scene)
    if _pending_callback.is_valid():
        _pending_callback.call()
        _pending_callback = Callable()

func _on_load_percent_changed(value: int) -> void :
    load_progress.emit(value)

func _on_load_finished() -> void :
    load_finished.emit()

func goto_scene(key: String, fade_speed: float = 0.5, callback: Callable = Callable()) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    scene_change_requested.emit(key)
    _pending_callback = callback

    var fade_opts = _plugin.create_options(fade_speed, "fade", 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, true, true)

    _plugin.change_scene(key, fade_opts, fade_opts, general_opts)

func goto_scene_with_pattern(key: String, pattern: String = "fade", fade_speed: float = 0.5, callback: Callable = Callable()) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    scene_change_requested.emit(key)
    _pending_callback = callback

    var fade_opts = _plugin.create_options(fade_speed, pattern, 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, true, true)

    _plugin.change_scene(key, fade_opts, fade_opts, general_opts)

func goto_scene_instant(key: String, callback: Callable = Callable()) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    scene_change_requested.emit(key)
    _pending_callback = callback
    _plugin.no_effect_change_scene(key)

func goto_scene_by_path(scene_path: String, callback: Callable = Callable()) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    scene_change_requested.emit(scene_path)
    _pending_callback = callback

    var packed_scene = load(scene_path)
    if packed_scene:
        _plugin._load_scene = scene_path
        _plugin.no_effect_change_scene(packed_scene)

func load(scene_path: String) -> PackedScene:
    if not ResourceLoader.exists(scene_path):
        push_error("SceneNavigator: scene not found: " + scene_path)
        return null
    return ResourceLoader.load(scene_path)

func reload_scene(fade_speed: float = 0.5, callback: Callable = Callable()) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    _pending_callback = callback

    var fade_opts = _plugin.create_options(fade_speed, "fade", 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, true, false)

    _plugin.change_scene("reload", fade_opts, fade_opts, general_opts)

func load_scene_async(key: String) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    _plugin.load_scene_interactive(key)

func change_to_loaded_scene(fade_speed: float = 0.5, callback: Callable = Callable()) -> void :
    if _plugin == null:
        push_error("SceneNavigator: plugin not found")
        return

    _pending_callback = callback

    var fade_opts = _plugin.create_options(fade_speed, "fade", 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, true, true)

    _plugin.change_scene_to_loaded_scene(fade_opts, fade_opts, general_opts)

func get_current_scene() -> String:
    if _plugin:
        return _plugin._current_scene
    return ""

func get_previous_scene() -> String:
    if _plugin:
        return _plugin.get_previous_scene()
    return ""

func set_back_limit(limit: int) -> void :
    if _plugin:
        _plugin.set_back_limit(limit)

func show_first_scene(fade_speed: float = 0.5, callback: Callable = Callable()) -> void :
    if _plugin == null:
        return

    _pending_callback = callback

    var fade_opts = _plugin.create_options(fade_speed, "fade", 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, true, true)

    _plugin.show_first_scene(fade_opts, general_opts)

func pause_scene(fade_speed: float = 0.5) -> void :
    if _plugin == null:
        return

    var fade_opts = _plugin.create_options(fade_speed, "fade", 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, false, true)

    _plugin.pause(fade_opts, general_opts)

func resume_scene(fade_speed: float = 0.5) -> void :
    if _plugin == null:
        return

    var fade_opts = _plugin.create_options(fade_speed, "fade", 0.1, false)
    var general_opts = _plugin.create_general_options(Color.BLACK, 0.0, true, true)

    _plugin.resume(fade_opts, general_opts)
