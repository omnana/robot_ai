class_name UIKeys extends RefCounted


const UI_DEFINITIONS: = {
    &"login": "res://resources/ui/login/UILoginPanel.tscn", 
    &"menu": "res://resources/ui/menu/UIMenuPanel.tscn", 
    &"level_select": "res://resources/ui/level/UILevelPanel.tscn", 
    &"game_hud": "res://resources/ui/game/UIGamePanel.tscn", 
    &"sample": "res://resources/ui/sample/UISamplePanel.tscn", 
    &"effect": "res://game/ui/effect/ui_effect_panel.tscn", 
    &"battle_result": "res://game/ui/battle_result/UIBattleResultPanel.tscn", 
}

static func register_all() -> void :
    UIRegistry.register_batch(UI_DEFINITIONS)

static func LOGIN_PANEL() -> RefCounted:
    return UIRegistry.get_key(&"login")

static func MENU_PANEL() -> RefCounted:
    return UIRegistry.get_key(&"menu")

static func LEVEL_SELECT_PANEL() -> RefCounted:
    return UIRegistry.get_key(&"level_select")

static func GAME_HUD() -> RefCounted:
    return UIRegistry.get_key(&"game_hud")

static func SAMPLE_PANEL() -> RefCounted:
    return UIRegistry.get_key(&"sample")

static func EFFECT_PANEL() -> RefCounted:
    return UIRegistry.get_key(&"effect")

static func BATTLE_RESULT() -> RefCounted:
    return UIRegistry.get_key(&"battle_result")
