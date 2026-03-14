class_name ButtonSound extends Control



@export var sound_path: String = "res://resources/audios/sfx/effect_button.mp3"

func _ready() -> void :
    var parent = get_parent()
    if parent and parent.has_signal("pressed"):
        parent.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void :
    AudioManager.play_se(sound_path)
