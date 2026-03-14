class_name UIEffectPanel
extends CanvasLayer


@onready var damage_vignette: DamageVignette = $DamageVignette


func _ready() -> void :
    layer = 100
    _connect_signals()


func _connect_signals() -> void :
    GameEventBus.damage_vignette_requested.connect(_on_damage_vignette_requested)


func _on_damage_vignette_requested(intensity: float, duration: float) -> void :
    show_damage_vignette(intensity, duration)


func show_damage_vignette(intensity: float = 0.5, duration: float = 0.3) -> void :
    if damage_vignette != null:
        damage_vignette.show_damage(intensity, duration)
