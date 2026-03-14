class_name UIToast extends UIComponent


var _message_queue: Array[Dictionary] = []
var _is_displaying: bool = false
var _display_timer: Timer
var _tween: Tween
var _layer: CanvasLayer

@onready var container: PanelContainer = $Container
@onready var message_label: Label = $Container / Message

static func show_message(message: String, duration: float = 2.0) -> void :
    var tree = Engine.get_main_loop()
    if not (tree and tree is SceneTree):
        return

    var layer: = CanvasLayer.new()
    layer.layer = 110
    layer.name = "ToastLayer"
    tree.root.add_child(layer)

    var toast_scene = load("res://resources/components/toast.tscn")
    if not toast_scene:
        push_error("UIToast: 无法加载场景")
        layer.queue_free()
        return

    var toast: = toast_scene.instantiate() as UIToast
    if not toast:
        push_error("UIToast: 无法实例化")
        layer.queue_free()
        return

    toast._layer = layer
    layer.add_child(toast)
    toast._show_message(message, duration)

func _on_init() -> void :
    anchor_left = 0.5
    anchor_right = 0.5
    anchor_top = 0.0
    anchor_bottom = 0.0
    offset_left = -200.0
    offset_top = 50.0
    offset_right = 200.0
    offset_bottom = 100.0

    _display_timer = Timer.new()
    _display_timer.one_shot = true
    _display_timer.timeout.connect(_on_display_timer_timeout)
    add_child(_display_timer)

    modulate.a = 0.0

func _show_message(message: String, duration: float = 2.0) -> void :
    _message_queue.append({"message": message, "duration": duration})
    _process_queue()

func _process_queue() -> void :
    if _is_displaying or _message_queue.is_empty():
        return

    _is_displaying = true
    visible = true
    var data: Dictionary = _message_queue.pop_front()
    message_label.text = data.message
    var duration: float = data.duration

    _fade_in_and_move_up()
    _display_timer.start(duration)

func _fade_in_and_move_up() -> void :
    if _tween:
        _tween.kill()
    _tween = create_tween()
    _tween.set_parallel(true)
    _tween.tween_property(self, "modulate:a", 1.0, 0.3)
    _tween.tween_property(self, "position:y", position.y - 150.0, 0.3).set_ease(Tween.EASE_OUT)

func _on_display_timer_timeout() -> void :
    _fade_out_and_move_down()

func _fade_out_and_move_down() -> void :
    if _tween:
        _tween.kill()
    _tween = create_tween()
    _tween.set_parallel(true)
    _tween.tween_property(self, "modulate:a", 0.0, 0.3)
    _tween.tween_property(self, "position:y", position.y - 100.0, 0.3).set_ease(Tween.EASE_OUT)
    _tween.set_parallel(false)
    _tween.tween_callback(_on_fade_out_complete)

func _on_fade_out_complete() -> void :
    _is_displaying = false

    if _message_queue.is_empty():
        if _layer:
            _layer.queue_free()
    else:
        _process_queue()
