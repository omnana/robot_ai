extends Node



signal asset_loaded(path: String, resource: Resource)
signal asset_unloaded(path: String)
signal load_progress(current: int, total: int)
signal pck_loaded(pck_path: String)
signal pck_unloaded(pck_path: String)

static var _instance: AssetManager = null

var _registry: AssetRegistry = null
var _dependency_analyzer: DependencyAnalyzer = null
var _cache: Dictionary = {}
var _loading: Dictionary = {}
var _loaded_pcks: Dictionary = {}

func _ready() -> void :
    _instance = self
    _registry = AssetRegistry.new()
    _dependency_analyzer = DependencyAnalyzer.new()

static func get_instance() -> AssetManager:
    return _instance

func load(path: String, use_cache: bool = true) -> Variant:
    if use_cache and _cache.has(path):
        return _cache[path]


    if _is_text_file(path):
        return _load_text_file(path, use_cache)

    if not ResourceLoader.exists(path):
        push_error("AssetManager: resource not found - %s" % path)
        return null

    var resource: = ResourceLoader.load(path)
    if resource == null:
        push_error("AssetManager: failed to load - %s" % path)
        return null

    if use_cache:
        _cache[path] = resource
        if _registry:
            _registry.register(path, resource)

    asset_loaded.emit(path, resource)
    return resource

func _is_text_file(path: String) -> bool:
    var ext = path.get_extension().to_lower()
    return ext == "csv" or ext == "txt" or ext == "json" or ext == "xml"

func _load_text_file(path: String, use_cache: bool = true) -> String:

    var file = FileAccess.open(path, FileAccess.READ)
    if file != null:
        var content = file.get_as_text()
        file.close()

        if use_cache:
            _cache[path] = content

        return content

    push_error("AssetManager: text file not found - %s" % path)
    return ""

func load_async(path: String, callback: Callable, use_cache: bool = true) -> void :
    if use_cache and _cache.has(path):
        callback.call(path, _cache[path])
        asset_loaded.emit(path, _cache[path])
        return

    if _loading.has(path):
        return


    if _is_text_file(path):
        var content = _load_text_file(path, use_cache)
        callback.call(path, content)
        return

    if not ResourceLoader.exists(path):
        push_error("AssetManager: resource not found - %s" % path)
        callback.call(path, null)
        return

    ResourceLoader.load_threaded_request(path)
    _loading[path] = true
    _check_loading_status(path, callback, use_cache)

func unload(path: String, force: bool = false) -> bool:
    if not _cache.has(path):
        return false

    _cache.erase(path)
    if _registry:
        _registry.unregister(path)
    asset_unloaded.emit(path)
    return true

func get_resource(path: String) -> Variant:
    return _cache.get(path)

func is_loaded(path: String) -> bool:
    return _cache.has(path)

func clear() -> void :
    _cache.clear()
    if _registry:
        _registry.clear()
    _loading.clear()

func _check_loading_status(path: String, callback: Callable, use_cache: bool) -> void :
    var status: = ResourceLoader.load_threaded_get_status(path)

    match status:
        ResourceLoader.THREAD_LOAD_LOADED:
            var resource: = ResourceLoader.load_threaded_get(path)
            _loading.erase(path)
            if use_cache and resource != null:
                _cache[path] = resource
                if _registry:
                    _registry.register(path, resource)
            callback.call(path, resource)
            asset_loaded.emit(path, resource)

        ResourceLoader.THREAD_LOAD_FAILED:
            _loading.erase(path)
            push_error("AssetManager: failed to load - %s" % path)
            callback.call(path, null)

        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            await get_tree().process_frame
            _check_loading_status(path, callback, use_cache)
