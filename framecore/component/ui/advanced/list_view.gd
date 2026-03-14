class_name UIListView extends UIComponent


signal on_item_clicked(index: int, data: Dictionary)

var _items: Array[Dictionary] = []
var _item_template: PackedScene = null
var _item_height: float = 50.0
var _buffer_count: int = 2

var _scroll_container: ScrollContainer
var _item_container: VBoxContainer

var _visible_start: int = 0
var _visible_end: int = 0
var _item_pool: Array[Control] = []
var _active_items: Dictionary = {}

var _spacer_top: Control
var _spacer_bottom: Control


func _on_init() -> void :
    visible = true
    _setup_ui()


func _setup_ui() -> void :
    _scroll_container = ScrollContainer.new()
    _scroll_container.name = "ScrollContainer"
    _scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(_scroll_container)

    _item_container = VBoxContainer.new()
    _item_container.name = "ItemContainer"
    _item_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _item_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    _scroll_container.add_child(_item_container)

    _spacer_top = Control.new()
    _spacer_top.name = "SpacerTop"
    _spacer_top.custom_minimum_size.y = 0
    _item_container.add_child(_spacer_top)

    _spacer_bottom = Control.new()
    _spacer_bottom.name = "SpacerBottom"
    _spacer_bottom.custom_minimum_size.y = 0
    _item_container.add_child(_spacer_bottom)

    _scroll_container.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)


func set_data(items: Array[Dictionary]) -> void :
    _items = items
    refresh()


func add_item(item: Dictionary) -> void :
    _items.append(item)
    refresh()


func remove_item(index: int) -> void :
    if index >= 0 and index < _items.size():
        _items.remove_at(index)
        refresh()


func refresh() -> void :
    var total_height: float = _items.size() * _item_height
    _spacer_bottom.custom_minimum_size.y = total_height

    _visible_start = 0
    _visible_end = 0
    _active_items.clear()

    for child in _item_container.get_children():
        if child != _spacer_top and child != _spacer_bottom:
            _item_pool.append(child)
            _item_container.remove_child(child)

    _update_visible_items()


func set_item_template(template: PackedScene) -> void :
    _item_template = template


func set_item_height(height: float) -> void :
    _item_height = height


func _on_scroll_changed(_value: float) -> void :
    _update_visible_items()


func _update_visible_items() -> void :
    if _items.is_empty():
        return

    var scroll_y: float = _scroll_container.scroll_vertical
    var viewport_height: float = _scroll_container.size.y

    var new_start: int = maxi(0, int(scroll_y / _item_height) - _buffer_count)
    var new_end: int = mini(_items.size(), int((scroll_y + viewport_height) / _item_height) + _buffer_count + 1)

    if new_start == _visible_start and new_end == _visible_end:
        return

    var indices_to_remove: Array[int] = []
    for index in _active_items.keys():
        if index < new_start or index >= new_end:
            indices_to_remove.append(index)

    for index in indices_to_remove:
        var item: Control = _active_items[index]
        _item_pool.append(item)
        _item_container.remove_child(item)
        _active_items.erase(index)

    _visible_start = new_start
    _visible_end = new_end

    _spacer_top.custom_minimum_size.y = _visible_start * _item_height

    for i in range(_visible_start, _visible_end):
        if not _active_items.has(i):
            var item: Control = _get_or_create_item()
            _setup_item(item, i, _items[i])
            _active_items[i] = item

            var insert_index: int = 1
            for existing_index in _active_items.keys():
                if existing_index < i and _item_container.is_ancestor_of(_active_items[existing_index]):
                    insert_index += 1
            _item_container.add_child(item)
            _item_container.move_child(item, insert_index)


func _get_or_create_item() -> Control:
    if not _item_pool.is_empty():
        return _item_pool.pop_back()

    if _item_template != null:
        return _item_template.instantiate() as Control

    var btn: = Button.new()
    btn.custom_minimum_size.y = _item_height
    btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return btn


func _setup_item(item: Control, index: int, data: Dictionary) -> void :
    if item is Button:
        var btn: Button = item as Button
        btn.text = data.get("text", "Item %d" % index)
        if btn.pressed.is_connected(_on_item_clicked):
            btn.pressed.disconnect(_on_item_clicked)
        btn.pressed.connect(_on_item_clicked.bind(index, data))

    item.set_meta("list_index", index)
    item.set_meta("list_data", data)


func _on_item_clicked(index: int, data: Dictionary) -> void :
    on_item_clicked.emit(index, data)


func get_items() -> Array[Dictionary]:
    return _items


func get_item_count() -> int:
    return _items.size()


func scroll_to_index(index: int) -> void :
    if index < 0 or index >= _items.size():
        return
    var target_y: float = index * _item_height
    _scroll_container.scroll_vertical = int(target_y)


func clear() -> void :
    _items.clear()
    refresh()
