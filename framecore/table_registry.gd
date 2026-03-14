extends Node






var _registered_tables: Array[String] = []


var _preloaded_tables: Array[String] = []


func _ready() -> void :

    preload_registered_tables()




func register_table(table_name: String) -> void :
    if table_name.is_empty():
        push_warning("[TableRegistry] Cannot register empty table name")
        return

    if _registered_tables.has(table_name):
        push_warning("[TableRegistry] Table '%s' is already registered" % table_name)
        return

    _registered_tables.append(table_name)
    print("[TableRegistry] Registered table: %s" % table_name)




func preload_registered_tables() -> void :
    if _registered_tables.is_empty():
        print("[TableRegistry] No tables registered for preloading")
        return

    print("[TableRegistry] Starting to preload %d registered tables..." % _registered_tables.size())

    var success_count: = 0
    var fail_count: = 0

    for table_name in _registered_tables:
        if _preload_table(table_name):
            success_count += 1
        else:
            fail_count += 1

    print("[TableRegistry] Preload complete. Success: %d, Failed: %d" % [success_count, fail_count])




func get_registered_tables() -> Array[String]:
    return _registered_tables.duplicate()




func get_preloaded_tables() -> Array[String]:
    return _preloaded_tables.duplicate()





func is_table_registered(table_name: String) -> bool:
    return _registered_tables.has(table_name)





func is_table_preloaded(table_name: String) -> bool:
    return _preloaded_tables.has(table_name)



func clear() -> void :
    _registered_tables.clear()
    _preloaded_tables.clear()
    print("[TableRegistry] All tables cleared")




func get_pending_tables() -> Array[String]:
    var pending: Array[String] = []
    for table_name in _registered_tables:
        if not _preloaded_tables.has(table_name):
            pending.append(table_name)
    return pending





func _preload_table(table_name: String) -> bool:

    if _preloaded_tables.has(table_name):
        return true


    var data = TableData.load_table(table_name)

    if data.is_empty():
        push_error("[TableRegistry] Failed to preload table: %s" % table_name)
        return false

    _preloaded_tables.append(table_name)
    print("[TableRegistry] Preloaded table: %s (%d rows)" % [table_name, data.size()])
    return true
