class_name AssetRegistry
extends RefCounted

class AssetInfo:
    var path: String
    var ref_count: int
    var resource_type: String

    func _init(p_path: String, p_resource: Resource):
        path = p_path
        ref_count = 1
        resource_type = p_resource.get_class()

var _assets: Dictionary = {}

func register(path: String, resource: Resource) -> void :
    if _assets.has(path):
        return
    _assets[path] = AssetInfo.new(path, resource)

func unregister(path: String) -> bool:
    if not _assets.has(path):
        return false
    _assets.erase(path)
    return true

func get_info(path: String) -> AssetInfo:
    return _assets.get(path)

func clear() -> void :
    _assets.clear()
