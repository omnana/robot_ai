extends Node

var _bgm_player: AudioStreamPlayer
var _se_player: AudioStreamPlayer
var _bgm_volume_db: float = 0.0
var _se_volume_db: float = 0.0
var _current_bgm_path: String = ""

func _ready() -> void :
    _bgm_player = AudioStreamPlayer.new()
    _bgm_player.bus = &"Master"
    add_child(_bgm_player)
    _se_player = AudioStreamPlayer.new()
    _se_player.bus = &"Master"
    add_child(_se_player)
    _apply_volumes_from_config()

func _apply_volumes_from_config() -> void :
    if ConfigManager:
        var bgm: float = ConfigManager.get_value(ConfigManager.SECTION_AUDIO, ConfigManager.KEY_BGM_VOLUME, 1.0)
        var se: float = ConfigManager.get_value(ConfigManager.SECTION_AUDIO, ConfigManager.KEY_SE_VOLUME, 1.0)
        set_bgm_volume_linear(bgm)
        set_se_volume_linear(se)

func set_bgm_volume_linear(linear: float) -> void :
    _bgm_volume_db = linear_to_db(clampf(linear, 0.0, 1.0))
    if _bgm_player.playing:
        _bgm_player.volume_db = _bgm_volume_db

func set_se_volume_linear(linear: float) -> void :
    _se_volume_db = linear_to_db(clampf(linear, 0.0, 1.0))
    _se_player.volume_db = _se_volume_db

func play_bgm(resource_path: String) -> void :
    var stream: AudioStream = load(resource_path) as AudioStream
    if stream == null:
        return
    _bgm_player.stream = stream
    _bgm_player.volume_db = _bgm_volume_db
    _bgm_player.play()
    _current_bgm_path = resource_path
    EventBus.bgm_started.emit(resource_path)

func stop_bgm() -> void :
    _bgm_player.stop()

func play_se(resource_path: String) -> void :
    var stream: AudioStream = load(resource_path) as AudioStream
    if stream == null:
        return
    _se_player.stream = stream
    _se_player.volume_db = _se_volume_db
    _se_player.play()
    EventBus.se_played.emit(resource_path)

func is_bgm_playing() -> bool:
    return _bgm_player.playing

func is_bgm_playing_path(resource_path: String) -> bool:
    return _bgm_player.playing and _current_bgm_path == resource_path
