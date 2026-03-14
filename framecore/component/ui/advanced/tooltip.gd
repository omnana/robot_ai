class_name UITooltip extends UIComponent


@export var follow_mouse: bool = true
@export var target_node: Control
@export var delay: float = 0.5
@export var text: String = "":
    set(value):
        text = value
        _update_text()

var _content_label: Label
var _panel: PanelContainer
var _delay_timer: Timer
var _is_waiting: bool = false
var _layer: CanvasLayer

static func create_for_target(target: Control, text_content: String, tooltip_delay: float = 0.5, follow: bool = true) -> UITooltip:
    var tree = Engine.get_main_loop()
    if not (tree and tree is SceneTree):
        return null

    var layer: = CanvasLayer.new()
    layer.layer = 120
    layer.name = "TooltipLayer"
    tree.root.add_child.call_deferred(layer)

    var tooltip_scene = load("res://resources/components/tooltip.tscn")
    if not tooltip_scene:
        push_error("UITooltip: 无法加载场景")
        layer.queue_free()
        return null

    var tooltip: = tooltip_scene.instantiate() as UITooltip
    if not tooltip:
        push_error("UITooltip: 无法实例化")
        layer.queue_free()
        return null

    tooltip._layer = layer
    layer.add_child.call_deferred(tooltip)

    tooltip.target_node = target
    tooltip.follow_mouse = follow
    tooltip.text = text_content
    tooltip.delay = tooltip_delay
    tooltip._setup_target.call_deferred()

    return tooltip

func _on_init() -> void :
    _setup_nodes()
    _setup_timer()

func _setup_nodes() -> void :
    _panel = get_node_or_null("PanelContainer")
    if _panel:
        _content_label = _panel.get_node_or_null("Content")
        if _content_label:
            _content_label.text = text

func _setup_timer() -> void :
    _delay_timer = Timer.new()
    _delay_timer.one_shot = true
    _delay_timer.wait_time = delay
    _delay_timer.timeout.connect(_on_delay_timeout)
    add_child(_delay_timer)

func _setup_target() -> void :
    if target_node:
        if target_node.mouse_entered.is_connected(_on_target_mouse_entered):
            target_node.mouse_entered.disconnect(_on_target_mouse_entered)
        if target_node.mouse_exited.is_connected(_on_target_mouse_exited):
            target_node.mouse_exited.disconnect(_on_target_mouse_exited)

        target_node.mouse_entered.connect(_on_target_mouse_entered)
        target_node.mouse_exited.connect(_on_target_mouse_exited)

    visible = false

func _process(_delta: float) -> void :
    if not visible:
        return

    if follow_mouse:
        _update_position(get_viewport().get_mouse_position())

func _update_position(target_pos: Vector2) -> void :
    var viewport_rect = get_viewport().get_visible_rect()
    var tooltip_size = size

    var new_pos = target_pos + Vector2(15, 15)

    if new_pos.x + tooltip_size.x > viewport_rect.size.x:
        new_pos.x = target_pos.x - tooltip_size.x - 5

    if new_pos.y + tooltip_size.y > viewport_rect.size.y:
        new_pos.y = target_pos.y - tooltip_size.y - 5

    if new_pos.x < 0:
        new_pos.x = 0

    if new_pos.y < 0:
        new_pos.y = 0

    global_position = new_pos

func _update_text() -> void :
    if _content_label:
        _content_label.text = text

func _on_target_mouse_entered() -> void :
    if delay > 0:
        _is_waiting = true
        _delay_timer.start()
    else:
        _show_tooltip()

func _on_target_mouse_exited() -> void :
    _is_waiting = false
    _delay_timer.stop()
    visible = false

func _on_delay_timeout() -> void :
    if _is_waiting:
        _show_tooltip()

func _show_tooltip() -> void :
    visible = true
    if follow_mouse:
        _update_position(get_viewport().get_mouse_position())

func set_text(new_text: String) -> void :
    text = new_text

func set_delay(new_delay: float) -> void :
    delay = new_delay
    if _delay_timer:
        _delay_timer.wait_time = delay

func set_target(node: Control) -> void :
    target_node = node
    _setup_target()

func destroy() -> void :
    if target_node:
        if target_node.mouse_entered.is_connected(_on_target_mouse_entered):
            target_node.mouse_entered.disconnect(_on_target_mouse_entered)
        if target_node.mouse_exited.is_connected(_on_target_mouse_exited):
            target_node.mouse_exited.disconnect(_on_target_mouse_exited)

    if _layer:
        _layer.queue_free()
    else:
        queue_free()
