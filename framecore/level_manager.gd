







extends Node



@export var level_table_name: String = "levels"

@export var default_save_slot: int = 1



var _progress: Dictionary = {
    "current_level_id": 0, 
    "completed_levels": {}, 
    "unlocked_levels": [], 
    "total_stars": 0
}



var _levels_cache: Array[Dictionary] = []

var _initialized: bool = false



func _ready() -> void :
    _load_table_data()
    load_progress()



func _load_table_data() -> void :
    _levels_cache = TableData.get_all(level_table_name)
    _initialized = true
    print("[LevelManager] 加载关卡数据: ", _levels_cache.size(), " 条")







func get_level(level_id: int) -> Dictionary:
    return TableData.get_by_id(level_table_name, level_id)




func get_all_levels() -> Array[Dictionary]:
    return _levels_cache.duplicate(true)






func get_current_level() -> Dictionary:
    var level_id = _progress.get("current_level_id", 0)
    if level_id == 0:
        if _levels_cache.size() > 0:
            return _levels_cache[0]
        return {}
    return get_level(level_id)




func get_next_level() -> Dictionary:
    var current_level = get_current_level()
    if current_level.is_empty():
        return {}

    var current_id = current_level.get("id", 0)

    for i in range(_levels_cache.size()):
        if _levels_cache[i].get("id") == current_id:
            if i + 1 < _levels_cache.size():
                return _levels_cache[i + 1]
            break

    return {}




func set_current_level(level_id: int) -> void :
    _progress["current_level_id"] = level_id
    print("[LevelManager] 设置当前关卡: ", level_id)








func complete_level(level_id: int, stars: int = 0, score: int = 0) -> void :
    var completed_levels: Dictionary = _progress.get("completed_levels", {})
    var current_record: Dictionary = completed_levels.get(level_id, {})

    var old_stars = current_record.get("stars", 0)
    var new_stars = maxi(old_stars, stars)

    var old_score = current_record.get("best_score", 0)
    var new_score = maxi(old_score, score)

    var completed_at = Time.get_datetime_string_from_system()

    completed_levels[level_id] = {
        "stars": new_stars, 
        "best_score": new_score, 
        "completed_at": completed_at
    }
    _progress["completed_levels"] = completed_levels

    _update_total_stars()
    _unlock_next_level(level_id)

    print("[LevelManager] 通关关卡: ", level_id, ", 星星: ", stars, ", 得分: ", score)





func get_level_progress(level_id: int) -> Dictionary:
    var completed_levels: Dictionary = _progress.get("completed_levels", {})
    return completed_levels.get(level_id, {
        "stars": 0, 
        "best_score": 0, 
        "completed_at": ""
    })



func _update_total_stars() -> void :
    var total = 0
    var completed_levels: Dictionary = _progress.get("completed_levels", {})
    for level_id in completed_levels:
        var record: Dictionary = completed_levels[level_id]
        total += record.get("stars", 0)
    _progress["total_stars"] = total




func _unlock_next_level(level_id: int) -> void :
    for i in range(_levels_cache.size()):
        if _levels_cache[i].get("id") == level_id:
            if i + 1 < _levels_cache.size():
                var next_level_id: int = int(_levels_cache[i + 1].get("id", 0))
                if not is_level_unlocked(next_level_id):
                    var unlocked_levels: Array = _progress.get("unlocked_levels", [])
                    unlocked_levels.append(next_level_id)
                    _progress["unlocked_levels"] = unlocked_levels
                    print("[LevelManager] 解锁关卡: ", next_level_id)
            break







func is_level_unlocked(level_id: int) -> bool:
    var unlocked_levels: Array = _progress.get("unlocked_levels", [])
    var check_id = float(level_id)
    return check_id in unlocked_levels or level_id in unlocked_levels





func save_progress() -> void :
    var save_data = {
        "level_progress": _progress
    }
    var success = SaveManager.save(default_save_slot, save_data)
    if success:
        print("[LevelManager] 保存进度成功")
    else:
        push_error("[LevelManager] 保存进度失败")



func load_progress() -> void :
    var save_data = SaveManager.load(default_save_slot)

    if save_data.is_empty():
        _init_default_progress()
        print("[LevelManager] 初始化默认进度")
    else:
        var level_progress = save_data.get("level_progress", {})
        if level_progress.is_empty():
            _init_default_progress()
        else:
            _progress = level_progress
            print("[LevelManager] 加载进度成功")



func _init_default_progress() -> void :
    _progress = {
        "current_level_id": 0, 
        "completed_levels": {}, 
        "unlocked_levels": [], 
        "total_stars": 0
    }

    if _levels_cache.size() > 0:
        var first_level_id: int = int(_levels_cache[0].get("id", 0))
        _progress["unlocked_levels"].append(first_level_id)
        _progress["current_level_id"] = first_level_id
        print("[LevelManager] 解锁第一关: ", first_level_id)






func get_level_count() -> int:
    return _levels_cache.size()




func get_completed_count() -> int:
    var completed_levels: Dictionary = _progress.get("completed_levels", {})
    return completed_levels.size()




func get_total_stars() -> int:
    return _progress.get("total_stars", 0)



func reset_progress() -> void :
    _init_default_progress()
    save_progress()
    print("[LevelManager] 重置所有进度")




func is_initialized() -> bool:
    return _initialized
