extends Node



const SETTINGS_PATH: = "user://settings.cfg"

const SECTION_DISPLAY: = "display"
const SECTION_AUDIO: = "audio"
const SECTION_INPUT: = "input"

const KEY_FULLSCREEN: = "fullscreen"
const KEY_WINDOW_WIDTH: = "window_width"
const KEY_WINDOW_HEIGHT: = "window_height"
const KEY_VSYNC: = "vsync"
const KEY_BGM_VOLUME: = "bgm_volume"
const KEY_SE_VOLUME: = "se_volume"

var _config: ConfigFile

func _ready() -> void :
    _config = ConfigFile.new()
    _load()

func _load() -> void :
    var err: = _config.load(SETTINGS_PATH)
    if err != OK:
        _set_defaults()
        save()

func _set_defaults() -> void :
    if not _config.has_section_key(SECTION_DISPLAY, KEY_FULLSCREEN):
        _config.set_value(SECTION_DISPLAY, KEY_FULLSCREEN, false)
    if not _config.has_section_key(SECTION_DISPLAY, KEY_WINDOW_WIDTH):
        _config.set_value(SECTION_DISPLAY, KEY_WINDOW_WIDTH, 1152)
    if not _config.has_section_key(SECTION_DISPLAY, KEY_WINDOW_HEIGHT):
        _config.set_value(SECTION_DISPLAY, KEY_WINDOW_HEIGHT, 648)
    if not _config.has_section_key(SECTION_DISPLAY, KEY_VSYNC):
        _config.set_value(SECTION_DISPLAY, KEY_VSYNC, 1)
    if not _config.has_section_key(SECTION_AUDIO, KEY_BGM_VOLUME):
        _config.set_value(SECTION_AUDIO, KEY_BGM_VOLUME, 1.0)
    if not _config.has_section_key(SECTION_AUDIO, KEY_SE_VOLUME):
        _config.set_value(SECTION_AUDIO, KEY_SE_VOLUME, 1.0)

func get_value(section: StringName, key: StringName, default: Variant = null) -> Variant:
    if not _config.has_section_key(section, key):
        return default
    return _config.get_value(section, key, default)

func set_value(section: StringName, key: StringName, value: Variant) -> void :
    _config.set_value(section, key, value)

func save() -> bool:
    return _config.save(SETTINGS_PATH) == OK

func apply_settings() -> void :

    var fullscreen: bool = get_value(SECTION_DISPLAY, KEY_FULLSCREEN, false)
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        var w: int = get_value(SECTION_DISPLAY, KEY_WINDOW_WIDTH, 1152)
        var h: int = get_value(SECTION_DISPLAY, KEY_WINDOW_HEIGHT, 648)
        DisplayServer.window_set_size(Vector2i(w, h))
    var vsync: int = get_value(SECTION_DISPLAY, KEY_VSYNC, 1)
    DisplayServer.window_set_vsync_mode(vsync)
