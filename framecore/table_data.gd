







extends Node



var _cache: Dictionary = {}


const TABLE_PATH_TEMPLATE_JSON = "res://resources/tables/{table_name}.json"
const TABLE_PATH_TEMPLATE_CSV = "res://resources/tables/{table_name}.csv"



func _ready() -> void :
    pass






func load_table(table_name: String) -> Array[Dictionary]:

    if _cache.has(table_name):
        return _cache[table_name]


    var file_path = TABLE_PATH_TEMPLATE_JSON.format({"table_name": table_name})


    var content = _load_table_content(file_path)
    if content.is_empty():

        file_path = TABLE_PATH_TEMPLATE_CSV.format({"table_name": table_name})
        content = _load_table_content(file_path)
        if content.is_empty():
            push_error("表格文件不存在或无法加载: " + file_path)
            return []


    var data: Array[Dictionary] = []
    if file_path.ends_with(".json"):
        data = _parse_json(content)
    else:
        data = TableLoader.parse_csv(content)


    _cache[table_name] = data

    print("[TableData] 加载表格: ", table_name, ", 行数: ", data.size())

    return data



func _load_table_content(file_path: String) -> String:

    var resource = AssetManager.load(file_path, false)
    if resource is String and not resource.is_empty():
        return resource


    var file = FileAccess.open(file_path, FileAccess.READ)
    if file != null:
        var content = file.get_as_text()
        file.close()
        return content

    return ""



func _parse_json(content: String) -> Array[Dictionary]:
    var json = JSON.new()
    var error = json.parse(content)
    if error != OK:
        push_error("[TableData] JSON 解析错误: " + json.get_error_message())
        return []

    var data = json.data
    if data is Array:
        var result: Array[Dictionary] = []
        for item in data:
            if item is Dictionary:
                result.append(item)
        return result

    return []






func get_by_id(table_name: String, id: int) -> Dictionary:
    var data = load_table(table_name)

    for row in data:
        if row.get("id") == id:
            return row

    push_warning("[TableData] 未找到数据: table=" + table_name + ", id=" + str(id))
    return {}






func query(table_name: String, condition: Callable) -> Array[Dictionary]:
    var data = load_table(table_name)
    var result: Array[Dictionary] = []

    for row in data:
        if condition.call(row):
            result.append(row)

    return result





func get_all(table_name: String) -> Array[Dictionary]:
    return load_table(table_name)





func reload(table_name: String) -> void :

    if _cache.has(table_name):
        _cache.erase(table_name)
        print("[TableData] 清除缓存: ", table_name)


    load_table(table_name)
    print("[TableData] 热重载完成: ", table_name)



func reload_all() -> void :
    var table_names = _cache.keys()
    for table_name in table_names:
        reload(table_name)





func is_cached(table_name: String) -> bool:
    return _cache.has(table_name)




func clear_cache(table_name: String) -> void :
    if _cache.has(table_name):
        _cache.erase(table_name)
        print("[TableData] 清除缓存: ", table_name)



func clear_all_cache() -> void :
    _cache.clear()
    print("[TableData] 清除所有缓存")




func get_cached_tables() -> Array[String]:
    var result: Array[String] = []
    for table_name in _cache.keys():
        result.append(table_name)
    return result





func get_row_count(table_name: String) -> int:
    var data = load_table(table_name)
    return data.size()
