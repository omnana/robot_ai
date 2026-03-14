extends UIPanel


var _victory: bool = false


func _on_show(data: Dictionary) -> void:
	if data.has("victory"):
		_victory = data["victory"]

	_build_ui()


func _build_ui() -> void:
	# 全屏半透明遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# 结果容器（居中）
	var container = VBoxContainer.new()
	container.name = "Container"
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 50)
	add_child(container)

	# 标题
	var title = Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if _victory:
		title.text = "胜 利"
		title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		title.text = "失 败"
		title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	title.add_theme_font_size_override("font_size", 120)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	container.add_child(title)

	# 副标题
	var subtitle = Label.new()
	subtitle.name = "Subtitle"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 36)
	subtitle.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))

	if _victory:
		subtitle.text = "Boss已被击败！"
	else:
		subtitle.text = "你倒下了..."

	container.add_child(subtitle)

	# 按钮容器
	var btn_container = HBoxContainer.new()
	btn_container.name = "ButtonContainer"
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 40)
	container.add_child(btn_container)

	# 返回按钮
	var back_btn = Button.new()
	back_btn.name = "BackButton"
	back_btn.text = "返回选关"
	back_btn.custom_minimum_size = Vector2(220, 65)
	back_btn.add_theme_font_size_override("font_size", 30)
	back_btn.pressed.connect(_on_back_pressed)
	btn_container.add_child(back_btn)

	# 重试按钮（失败时显示）
	if not _victory:
		var retry_btn = Button.new()
		retry_btn.name = "RetryButton"
		retry_btn.text = "再试一次"
		retry_btn.custom_minimum_size = Vector2(220, 65)
		retry_btn.add_theme_font_size_override("font_size", 30)
		retry_btn.pressed.connect(_on_retry_pressed)
		btn_container.add_child(retry_btn)

	# 入场动画
	_play_entrance_animation(container, title)


func _play_entrance_animation(container: Control, title: Label) -> void:
	container.modulate.a = 0
	container.scale = Vector2(0.8, 0.8)
	container.pivot_offset = container.size / 2

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(container, "modulate:a", 1.0, 0.5)
	tween.tween_property(container, "scale", Vector2.ONE, 0.5)


func _on_back_pressed() -> void:
	UIManager.close_ui(UIKeys.EFFECT_PANEL())
	UIManager.close_all()
	SceneNavigator.goto_scene("entry", 0.5, func():
		UIManager.open(UIKeys.LEVEL_SELECT_PANEL())
		if not AudioManager.is_bgm_playing_path("res://resources/audios/music/bgm_menu.mp3"):
			AudioManager.play_bgm("res://resources/audios/music/bgm_menu.mp3")
	)


func _on_retry_pressed() -> void:
	UIManager.close_all()
	SceneNavigator.goto_scene("level_map", 0.5)
