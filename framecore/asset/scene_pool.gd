class_name ScenePool extends Node



signal scene_preloaded(scene_path: String)
signal preload_progress(current: int, total: int)
signal preload_completed()

var _scene_cache: Dictionary = {}

func preload_scene(scene_path: String) -> void :
    if _scene_cache.has(scene_path):
        return

    if not ResourceLoader.exists(scene_path):
        push_error("ScenePool: scene not found - %s" % scene_path)
        return

    var packed: = ResourceLoader.load(scene_path) as PackedScene
    if packed:
        _scene_cache[scene_path] = packed
        scene_preloaded.emit(scene_path)

func preload_scene_async(scene_path: String) -> void :
    if _scene_cache.has(scene_path):
        scene_preloaded.emit(scene_path)
        return

    if not ResourceLoader.exists(scene_path):
        push_error("ScenePool: scene not found - %s" % scene_path)
        return

    ResourceLoader.load_threaded_request(scene_path)

    while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().process_frame

    var status: = ResourceLoader.load_threaded_get_status(scene_path)
    if status == ResourceLoader.THREAD_LOAD_LOADED:
        var packed: = ResourceLoader.load_threaded_get(scene_path) as PackedScene
        if packed:
            _scene_cache[scene_path] = packed
            scene_preloaded.emit(scene_path)
    else:
        push_error("ScenePool: failed to preload - %s" % scene_path)

func preload_scenes(scene_paths: Array[String]) -> void :
    var total: = scene_paths.size()
    var current: = 0

    for path in scene_paths:
        preload_scene(path)
        current += 1
        preload_progress.emit(current, total)

    preload_completed.emit()

func preload_scenes_async(scene_paths: Array[String]) -> void :
    var total: = scene_paths.size()
    var current: = 0

    for path in scene_paths:
        if _scene_cache.has(path):
            current += 1
            preload_progress.emit(current, total)
            continue

        if not ResourceLoader.exists(path):
            current += 1
            preload_progress.emit(current, total)
            continue

        ResourceLoader.load_threaded_request(path)

    for path in scene_paths:
        if _scene_cache.has(path):
            continue

        while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            await get_tree().process_frame

        var status: = ResourceLoader.load_threaded_get_status(path)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            var packed: = ResourceLoader.load_threaded_get(path) as PackedScene
            if packed:
                _scene_cache[path] = packed

        current += 1
        preload_progress.emit(current, total)

    preload_completed.emit()

func get_scene(scene_path: String) -> PackedScene:
    if not _scene_cache.has(scene_path):
        preload_scene(scene_path)
    return _scene_cache.get(scene_path)

func has_scene(scene_path: String) -> bool:
    return _scene_cache.has(scene_path)

func instantiate_scene(scene_path: String) -> Node:
    var packed: = get_scene(scene_path)
    if packed:
        return packed.instantiate()
    return null

func unload_scene(scene_path: String) -> void :
    _scene_cache.erase(scene_path)

func clear_cache() -> void :
    _scene_cache.clear()

func get_cache_count() -> int:
    return _scene_cache.size()
