extends UIPanel


@onready var message_box_script = AssetManager.load("res://framecore/component/ui/advanced/message_box.gd")
@onready var toast_script = AssetManager.load("res://framecore/component/ui/advanced/toast.gd")
@onready var tooltip_script = AssetManager.load("res://framecore/component/ui/advanced/tooltip.gd")


@onready var confirm_btn: Button = $VBoxContainer / MessageBoxSection / HBoxContainer / ConfirmBtn
@onready var alert_btn: Button = $VBoxContainer / MessageBoxSection / HBoxContainer / AlertBtn


@onready var short_btn: Button = $VBoxContainer / ToastSection / HBoxContainer / ShortBtn
@onready var long_btn: Button = $VBoxContainer / ToastSection / HBoxContainer / LongBtn


@onready var progress_bar: Control = $VBoxContainer / ProgressSection / ProgressBar
@onready var start_btn: Button = $VBoxContainer / ProgressSection / StartBtn


@onready var tooltip_btn: Button = $VBoxContainer / TooltipSection / TooltipBtn


@onready var list_view: Control = $VBoxContainer / ListViewSection / ListView
@onready var add_btn: Button = $VBoxContainer / ListViewSection / HBoxContainer / AddBtn
@onready var remove_btn: Button = $VBoxContainer / ListViewSection / HBoxContainer / RemoveBtn


@onready var close_btn: Button = $VBoxContainer / CloseBtn


var _progress_tween: Tween
var _list_item_count: int = 0

func _ready() -> void :
    _connect_signals()
    _init_list_view()

func _connect_signals() -> void :
    confirm_btn.pressed.connect(_on_confirm_btn_pressed)
    alert_btn.pressed.connect(_on_alert_btn_pressed)
    short_btn.pressed.connect(_on_short_btn_pressed)
    long_btn.pressed.connect(_on_long_btn_pressed)
    start_btn.pressed.connect(_on_start_btn_pressed)
    add_btn.pressed.connect(_on_add_btn_pressed)
    remove_btn.pressed.connect(_on_remove_btn_pressed)
    close_btn.pressed.connect(_on_close_btn_pressed)

func _init_list_view() -> void :
    if list_view and list_view.has_method("set_data"):
        var items: Array[Dictionary] = []
        list_view.set_data(items)

func _on_confirm_btn_pressed() -> void :
    if message_box_script and message_box_script.has_method("show_confirm"):
        message_box_script.show_confirm("确认操作", "确定要执行此操作吗？", _on_confirm_callback)

func _on_confirm_callback(button_index: int) -> void :
    if button_index == 1:
        if toast_script and toast_script.has_method("show_message"):
            toast_script.show_message("已确认操作")
    else:
        if toast_script and toast_script.has_method("show_message"):
            toast_script.show_message("已取消操作")

func _on_alert_btn_pressed() -> void :
    if message_box_script and message_box_script.has_method("show_alert"):
        message_box_script.show_alert("警告", "这是一个警告提示信息")

func _on_short_btn_pressed() -> void :
    if toast_script and toast_script.has_method("show_message"):
        toast_script.show_message("这是一条短提示", 1.5)

func _on_long_btn_pressed() -> void :
    if toast_script and toast_script.has_method("show_message"):
        toast_script.show_message("这是一条较长的提示信息，用于测试 Toast 组件的显示效果", 3.0)

func _on_start_btn_pressed() -> void :
    if _progress_tween and _progress_tween.is_valid():
        _progress_tween.kill()

    if progress_bar and progress_bar.has_method("set_ratio_immediate"):
        progress_bar.set_ratio_immediate(0.0)

    _progress_tween = create_tween()
    _progress_tween.tween_method(_update_progress, 0.0, 1.0, 3.0)
    _progress_tween.tween_callback(_on_progress_complete)

func _update_progress(value: float) -> void :
    if progress_bar and progress_bar.has_method("set_ratio"):
        progress_bar.set_ratio(value)

func _on_progress_complete() -> void :
    if toast_script and toast_script.has_method("show_message"):
        toast_script.show_message("进度完成")

func _on_show(_data: Dictionary) -> void :
    _setup_tooltip()

func _setup_tooltip() -> void :
    if tooltip_script and tooltip_script.has_method("create_for_target"):
        tooltip_script.create_for_target(tooltip_btn, "这是一个 Tooltip 提示", 0.3, true)

func _on_add_btn_pressed() -> void :
    _list_item_count += 1
    var new_item: Dictionary = {"text": "列表项 %d" % _list_item_count}
    if list_view and list_view.has_method("add_item"):
        list_view.add_item(new_item)

func _on_remove_btn_pressed() -> void :
    if list_view and list_view.has_method("get_item_count"):
        var count = list_view.get_item_count()
        if count > 0:
            list_view.remove_item(count - 1)

func _on_close_btn_pressed() -> void :
    close_panel()
