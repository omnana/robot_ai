class_name HitEffect
extends Node2D






signal effect_finished


@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


var _is_playing: bool = false


var _initialized: bool = false


func _ready() -> void :
    _load_frames()



func _load_frames() -> void :
    if _initialized:
        return

    var frames = _sprite.sprite_frames
    if frames == null:
        frames = SpriteFrames.new()
        _sprite.sprite_frames = frames


    if frames.has_animation("default"):
        frames.clear("default")
    else:
        frames.add_animation("default")

    var frame_paths = [
        "res://resources/animation/effect/gunfire/1.png", 
        "res://resources/animation/effect/gunfire/2.png", 
        "res://resources/animation/effect/gunfire/3.png", 
        "res://resources/animation/effect/gunfire/4.png"
    ]

    for frame_path in frame_paths:
        var texture = AssetManager.load(frame_path)
        if texture != null:
            frames.add_frame("default", texture)

    frames.set_animation_loop("default", false)
    frames.set_animation_speed("default", 15.0)

    _sprite.animation = "default"
    _initialized = true


func _process(_delta: float) -> void :
    if not _is_playing:
        return

    if _sprite != null and not _sprite.is_playing():
        _is_playing = false
        effect_finished.emit()



func on_spawn() -> void :
    _is_playing = true
    if _sprite != null:
        _sprite.play("default")



func on_despawn() -> void :
    _is_playing = false
    if _sprite != null and _sprite.is_playing():
        _sprite.stop()



func set_params(params: Dictionary) -> void :
    if params.has("scale"):
        scale = params["scale"]

    if params.has("z_index"):
        z_index = params["z_index"]
