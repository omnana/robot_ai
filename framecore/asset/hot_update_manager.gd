class_name HotUpdateManager extends Node




signal update_checked(result: Dictionary)
signal download_progress(current: int, total: int)
signal download_completed(save_path: String)
signal download_failed(error: String)
signal update_applied(pck_path: String)


const _version_file_path: String = "user://version.json"


var _http_request: HTTPRequest
var _download_http: HTTPRequest
var _is_downloading: bool = false
var _current_download_path: String = ""
var _server_url: String = ""


func _ready() -> void :

    _http_request = HTTPRequest.new()
    add_child(_http_request)
    _http_request.request_completed.connect(_on_version_check_completed)


    _download_http = HTTPRequest.new()
    add_child(_download_http)
    _download_http.request_completed.connect(_on_download_completed)







func check_update(server_url: String) -> Dictionary:
    _server_url = server_url
    var result: Dictionary = {
        "has_update": false, 
        "updates": [], 
        "version": ""
    }


    var version_url: String = server_url.trim_suffix("/") + "/version.json"
    var error: int = _http_request.request(version_url)

    if error != OK:
        result["has_update"] = false
        update_checked.emit(result)
        return result


    return result



func _on_version_check_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
    var check_result: Dictionary = {
        "has_update": false, 
        "updates": [], 
        "version": ""
    }

    if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
        update_checked.emit(check_result)
        return


    var json: JSON = JSON.new()
    var parse_error: int = json.parse(body.get_string_from_utf8())

    if parse_error != OK:
        update_checked.emit(check_result)
        return

    var server_info: Dictionary = json.data
    var server_version: String = server_info.get("version", "")
    var local_version: String = get_local_version()

    check_result["version"] = server_version


    if server_version != local_version:
        check_result["has_update"] = true
        check_result["updates"] = server_info.get("updates", [])

    update_checked.emit(check_result)







func download_update(update_info: Dictionary, save_path: String) -> void :
    if _is_downloading:
        download_failed.emit("已有下载任务在进行中")
        return

    _is_downloading = true
    _current_download_path = save_path


    var download_url: String = update_info.get("url", "")
    if download_url.is_empty():
        _is_downloading = false
        download_failed.emit("下载地址为空")
        return


    if not download_url.begins_with("http"):
        download_url = _server_url.trim_suffix("/") + "/" + download_url.lstrip("/")


    var downloaded_size: int = 0
    if FileAccess.file_exists(save_path):
        var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
        if file:
            downloaded_size = file.get_length()
            file.close()


    if downloaded_size > 0:
        _download_http.set_download_file(save_path)
        var headers: PackedStringArray = ["Range: bytes=" + str(downloaded_size) + "-"]
        var error: int = _download_http.request(download_url, headers)
        if error != OK:
            _is_downloading = false
            download_failed.emit("发起下载请求失败")
            return
    else:
        _download_http.set_download_file(save_path)
        var error: int = _download_http.request(download_url)
        if error != OK:
            _is_downloading = false
            download_failed.emit("发起下载请求失败")
            return


    _monitor_download_progress()



func _monitor_download_progress() -> void :
    while _is_downloading:
        var downloaded_bytes: int = _download_http.get_downloaded_bytes()
        var total_bytes: int = _download_http.get_body_size()

        if total_bytes > 0:
            download_progress.emit(downloaded_bytes, total_bytes)

        await get_tree().create_timer(0.1).timeout



func cancel_download() -> void :
    if not _is_downloading:
        return

    _is_downloading = false
    _download_http.cancel_request()


    if FileAccess.file_exists(_current_download_path):
        DirAccess.remove_absolute(_current_download_path)

    _current_download_path = ""



func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
    _is_downloading = false

    if result != HTTPRequest.RESULT_SUCCESS:

        if response_code == 206:
            download_completed.emit(_current_download_path)
            return

        download_failed.emit("下载失败，错误码: " + str(result))
        return

    download_completed.emit(_current_download_path)







func apply_update(pck_path: String) -> bool:

    if not FileAccess.file_exists(pck_path):
        push_error("PCK文件不存在: " + pck_path)
        return false


    var success: bool = ProjectSettings.load_resource_pack(pck_path)

    if not success:
        push_error("加载PCK文件失败: " + pck_path)
        return false



    var version: String = _extract_version_from_pck_path(pck_path)
    if not version.is_empty():
        set_local_version(version)

    update_applied.emit(pck_path)
    return true



func _extract_version_from_pck_path(pck_path: String) -> String:

    var file_name: String = pck_path.get_file()
    var regex: RegEx = RegEx.new()
    regex.compile("v(\\d+\\.\\d+\\.\\d+)")
    var result: RegExMatch = regex.search(file_name)

    if result:
        return result.get_string(1)

    return ""






func get_local_version() -> String:
    if not FileAccess.file_exists(_version_file_path):
        return "0.0.0"

    var file: FileAccess = FileAccess.open(_version_file_path, FileAccess.READ)
    if not file:
        return "0.0.0"

    var content: String = file.get_as_text()
    file.close()

    var json: JSON = JSON.new()
    if json.parse(content) != OK:
        return "0.0.0"

    var data: Dictionary = json.data
    return data.get("version", "0.0.0")




func set_local_version(version: String) -> void :
    var data: Dictionary = {
        "version": version, 
        "update_time": Time.get_datetime_string_from_system()
    }

    var file: FileAccess = FileAccess.open(_version_file_path, FileAccess.WRITE)
    if not file:
        push_error("无法写入版本文件")
        return

    file.store_string(JSON.stringify(data))
    file.close()
