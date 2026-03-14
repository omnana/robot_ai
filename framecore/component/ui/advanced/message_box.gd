class_name UIMessageBox extends UIComponent


const SCENE_PATH: String = "res://resources/components/message_box.tscn"

var _title_label: Label
var _content_label: Label
var _button_container: HBoxContainer
var _dialog: PanelContainer
var _mask: ColorRect

var _callback: Callable = Callable()

func _on_init() -> void :
    _setup_ui()

func _setup_ui() -> void :
    _mask = get_node_or_null("Mask")
    _dialog = get_node_or_null("Dialog")

    if _dialog:
        var vbox = _dialog.get_node_or_null("VBoxContainer")
        if vbox:
            _title_label = vbox.get_node_or_null("Title")
            _content_label = vbox.get_node_or_null("Content")
            _button_container = vbox.get_node_or_null("ButtonContainer")

func _on_show(data: Dictionary) -> void :
    _setup_dialog(data)

func _setup_dialog(data: Dictionary) -> void :
    if _title_label and data.has("title"):
        _title_label.text = data.get("title", "")

    if _content_label and data.has("content"):
        _content_label.text = data.get("content", "")

    _clear_buttons()

    var buttons_data = data.get("buttons", [])
    for btn in buttons_data:
        _create_button(btn)

    if data.has("callback"):
        _callback = data["callback"]
    else:
        _callback = Callable()

func _clear_buttons() -> void :
    if not _button_container:
        return

    for child in _button_container.get_children():
        child.queue_free()

func _create_button(button_data: Dictionary) -> void :
    if not _button_container:
        return

    var button = Button.new()
    button.text = button_data.get("text", "按钮")
    button.pressed.connect(_on_button_pressed.bind(_button_container.get_child_count()))
    _button_container.add_child(button)

func _on_button_pressed(button_index: int) -> void :
    if _callback.is_valid():
        _callback.call(button_index)
    hide_component()
    var parent: = get_parent()
    if parent and parent is CanvasLayer:
        parent.queue_free()
    else:
        queue_free()

static func show_confirm(title: String, content: String, callback: Callable = Callable()) -> UIMessageBox:
    var config: Dictionary = {
        "title": title, 
        "content": content, 
        "buttons": [
            {"text": "取消"}, 
            {"text": "确认"}
        ], 
        "callback": callback
    }
    return show_dialog(config)

static func show_alert(title: String, content: String, callback: Callable = Callable()) -> UIMessageBox:
    var config: Dictionary = {
        "title": title, 
        "content": content, 
        "buttons": [
            {"text": "确定"}
        ], 
        "callback": callback
    }
    return show_dialog(config)

static func show_dialog(config: Dictionary) -> UIMessageBox:
    var scene = load(SCENE_PATH)
    if not scene:
        push_error("无法加载 MessageBox 场景")
        return null

    var message_box = scene.instantiate()
    if not message_box:
        push_error("无法实例化 MessageBox")
        return null

    var tree = Engine.get_main_loop()
    if tree and tree is SceneTree:
        var layer: = CanvasLayer.new()
        layer.layer = 100
        layer.name = "MessageBoxLayer"
        tree.root.add_child(layer)
        layer.add_child(message_box)
        message_box.show_component(config)

    return message_box
