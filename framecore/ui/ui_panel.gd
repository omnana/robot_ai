extends Control
class_name UIPanel


signal panel_closed()

func show_panel(data: Dictionary = {}) -> void :
    show()
    _on_show(data)

func hide_panel() -> void :
    _on_hide()
    hide()

func close_panel() -> void :
    _on_close()
    panel_closed.emit()
    queue_free()

func _on_show(_data: Dictionary) -> void :
    pass

func _on_hide() -> void :
    pass

func _on_close() -> void :
    pass
