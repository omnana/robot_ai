extends Node


signal framework_ready()
signal game_state_changed(old_state: StringName, new_state: StringName)
signal scene_changed(scene_path: String)
signal scene_change_requested(scene_path: String)
signal ui_opened(ui_id: StringName)
signal ui_closed(ui_id: StringName)
signal save_requested(slot: int)
signal load_requested(slot: int)
signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)
signal bgm_started(resource_path: String)
signal se_played(resource_path: String)
signal input_map_changed()
signal asset_loaded(path: String, resource: Resource)
signal asset_unloaded(path: String)
