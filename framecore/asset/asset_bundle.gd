class_name AssetBundle extends RefCounted


signal loaded()
signal unloaded()


var bundle_name: String = ""
var version: String = "1.0.0"
var resources: Array[String] = []
var dependencies: Array[String] = []



func compare_version(other_version: String) -> int:
    var self_parts: = version.split(".")
    var other_parts: = other_version.split(".")

    var max_len: = maxi(self_parts.size(), other_parts.size())

    for i in max_len:
        var self_val: = _get_version_part(self_parts, i)
        var other_val: = _get_version_part(other_parts, i)

        if self_val < other_val:
            return -1
        elif self_val > other_val:
            return 1

    return 0



func _get_version_part(parts: PackedStringArray, index: int) -> int:
    if index >= parts.size():
        return 0
    return parts[index].to_int()



func to_dict() -> Dictionary:
    return {
        "bundle_name": bundle_name, 
        "version": version, 
        "resources": resources, 
        "dependencies": dependencies
    }



static func from_dict(data: Dictionary) -> AssetBundle:
    var bundle: = AssetBundle.new()
    bundle.bundle_name = data.get("bundle_name", "")
    bundle.version = data.get("version", "1.0.0")

    var res_data: Array = data.get("resources", [])
    bundle.resources.clear()
    for res in res_data:
        bundle.resources.append(res)

    var dep_data: Array = data.get("dependencies", [])
    bundle.dependencies.clear()
    for dep in dep_data:
        bundle.dependencies.append(dep)

    return bundle
