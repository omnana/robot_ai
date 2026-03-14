class_name AssetBundleBuilder extends RefCounted



enum PackStrategy{
    BY_MODULE, 
    BY_SCENE, 
    BY_UPDATE_FREQUENCY
}


var _packer: PCKPacker = null

var _output_path: String = ""

var _encrypt: bool = false

var _key: String = ""

var _files: Array[Dictionary] = []

var _created: bool = false



func create(output_path: String, encrypt: bool = false, key: String = "") -> AssetBundleBuilder:
    _output_path = output_path
    _encrypt = encrypt
    _key = key
    _packer = PCKPacker.new()

    var err: = _packer.pck_start(output_path, 0)
    if err != OK:
        push_error("创建 PCK 打包器失败: " + str(err))
        return null

    _created = true
    _files.clear()
    return self



func add_file(pck_path: String, source_path: String, encrypt: bool = false) -> Error:
    if not _created:
        push_error("打包器未创建，请先调用 create()")
        return ERR_UNCONFIGURED

    if not FileAccess.file_exists(source_path):
        push_error("源文件不存在: " + source_path)
        return ERR_FILE_NOT_FOUND

    var err: int
    if encrypt:
        err = _packer.add_file(pck_path, source_path, true)
    else:
        err = _packer.add_file(pck_path, source_path, false)

    if err != OK:
        push_error("添加文件失败: " + source_path + ", 错误: " + str(err))
        return err


    var file_info: = {
        "path": pck_path, 
        "source_path": source_path, 
        "hash": _compute_file_hash(source_path), 
        "size": _get_file_size(source_path)
    }
    _files.append(file_info)

    return OK



func add_directory(dir_path: String, pck_base_path: String = "res://") -> Error:
    if not _created:
        push_error("打包器未创建，请先调用 create()")
        return ERR_UNCONFIGURED

    var dir: = DirAccess.open(dir_path)
    if dir == null:
        push_error("无法打开目录: " + dir_path)
        return ERR_CANT_OPEN

    var err: = dir.list_dir_begin()
    if err != OK:
        return err

    var file_name: = dir.get_next()
    while file_name != "":
        if not dir.current_is_dir():
            var source_file: = dir_path.path_join(file_name)
            var pck_path: = pck_base_path.path_join(file_name)
            err = add_file(pck_path, source_file, _encrypt)
            if err != OK:
                dir.list_dir_end()
                return err
        file_name = dir.get_next()

    dir.list_dir_end()
    return OK



func build() -> Error:
    if not _created:
        push_error("打包器未创建，请先调用 create()")
        return ERR_UNCONFIGURED

    var err: = _packer.flush()
    if err != OK:
        push_error("打包失败: " + str(err))
        return err

    _created = false
    return OK



func generate_manifest() -> Dictionary:
    var manifest: = {
        "version": "1.0.0", 
        "build_time": Time.get_datetime_string_from_system(), 
        "output_path": _output_path, 
        "files": []
    }

    for file_info in _files:
        manifest["files"].append({
            "path": file_info["path"], 
            "hash": file_info["hash"], 
            "size": file_info["size"]
        })

    return manifest



func save_manifest(manifest_path: String) -> Error:
    var manifest: = generate_manifest()
    var json_string: = JSON.stringify(manifest, "  ")

    var file: = FileAccess.open(manifest_path, FileAccess.WRITE)
    if file == null:
        push_error("无法创建清单文件: " + manifest_path)
        return ERR_CANT_CREATE

    file.store_string(json_string)
    file.close()

    return OK



func build_with_strategy(strategy: int, config: Dictionary) -> Array[String]:
    var pck_paths: Array[String] = []

    match strategy:
        PackStrategy.BY_MODULE:
            pck_paths = _build_by_module(config)
        PackStrategy.BY_SCENE:
            pck_paths = _build_by_scene(config)
        PackStrategy.BY_UPDATE_FREQUENCY:
            pck_paths = _build_by_frequency(config)
        _:
            push_error("未知的打包策略: " + str(strategy))

    return pck_paths



func _build_by_module(config: Dictionary) -> Array[String]:
    var pck_paths: Array[String] = []
    var modules: Dictionary = config.get("modules", {})
    var base_output_dir: String = config.get("output_dir", "res://packs")

    for module_name in modules:
        var module_files: Array = modules[module_name]
        var output_path: = base_output_dir.path_join(module_name + ".pck")

        var builder: = create(output_path, _encrypt, _key)
        if builder == null:
            continue

        for file_info in module_files:
            var source_path: String = file_info.get("source", "")
            var pck_path: String = file_info.get("pck_path", source_path)
            add_file(pck_path, source_path, _encrypt)

        if build() == OK:
            pck_paths.append(output_path)

    return pck_paths



func _build_by_scene(config: Dictionary) -> Array[String]:
    var pck_paths: Array[String] = []
    var scenes: Dictionary = config.get("scenes", {})
    var base_output_dir: String = config.get("output_dir", "res://packs")

    for scene_name in scenes:
        var scene_files: Array = scenes[scene_name]
        var output_path: = base_output_dir.path_join(scene_name + ".pck")

        var builder: = create(output_path, _encrypt, _key)
        if builder == null:
            continue

        for file_info in scene_files:
            var source_path: String = file_info.get("source", "")
            var pck_path: String = file_info.get("pck_path", source_path)
            add_file(pck_path, source_path, _encrypt)

        if build() == OK:
            pck_paths.append(output_path)

    return pck_paths



func _build_by_frequency(config: Dictionary) -> Array[String]:
    var pck_paths: Array[String] = []
    var frequency_groups: Dictionary = config.get("frequency_groups", {})
    var base_output_dir: String = config.get("output_dir", "res://packs")

    for freq_name in frequency_groups:
        var files: Array = frequency_groups[freq_name]
        var output_path: = base_output_dir.path_join(freq_name + ".pck")

        var builder: = create(output_path, _encrypt, _key)
        if builder == null:
            continue

        for file_info in files:
            var source_path: String = file_info.get("source", "")
            var pck_path: String = file_info.get("pck_path", source_path)
            add_file(pck_path, source_path, _encrypt)

        if build() == OK:
            pck_paths.append(output_path)

    return pck_paths



func _compute_file_hash(file_path: String) -> String:
    var file: = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        return ""

    var content: = file.get_buffer(file.get_length())
    file.close()

    var hashing: = HashingContext.new()
    hashing.start(HashingContext.HASH_MD5)
    hashing.update(content)
    var hash: = hashing.finish()

    return hash.hex_encode()



func _get_file_size(file_path: String) -> int:
    var file: = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        return 0

    var size: = file.get_length()
    file.close()
    return size



static func pack_bundle(bundle: AssetBundle, output_path: String, encrypt: bool = false) -> Error:
    if bundle == null:
        push_error("资源包为空")
        return ERR_INVALID_PARAMETER

    var builder: = AssetBundleBuilder.new()
    builder.create(output_path, encrypt)

    for resource_path in bundle.resources:
        if FileAccess.file_exists(resource_path):
            builder.add_file(resource_path, resource_path, encrypt)

    return builder.build()



static func pack_directory(dir_path: String, output_path: String, encrypt: bool = false) -> Error:
    var builder: = AssetBundleBuilder.new()
    builder.create(output_path, encrypt)

    var err: = builder.add_directory(dir_path)
    if err != OK:
        return err

    return builder.build()
