extends IGameEntry


func on_framework_ready() -> void :

    UIKeys.register_all()


    if not AudioManager.is_bgm_playing_path("res://resources/audios/music/bgm_menu.mp3"):
        AudioManager.play_bgm("res://resources/audios/music/bgm_menu.mp3")


    UIManager.open(UIKeys.LOGIN_PANEL())


    EventBus.framework_ready.emit()
