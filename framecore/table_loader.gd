



class_name TableLoader



static func parse_csv_from_file(file_path: String) -> Array[Dictionary]:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        push_error("无法打开文件: " + file_path)
        return []

    var content = file.get_as_text()
    file.close()

    return parse_csv(content)



static func parse_csv(content: String) -> Array[Dictionary]:
    if content.is_empty():
        return []

    var lines = _split_lines(content)
    if lines.is_empty():
        return []


    var headers = _parse_line(lines[0])
    if headers.is_empty():
        return []

    var result: Array[Dictionary] = []


    for i in range(1, lines.size()):
        var line = lines[i].strip_edges()
        if line.is_empty():
            continue

        var values = _parse_line(lines[i])
        var row: Dictionary = {}

        for j in range(min(headers.size(), values.size())):
            var key = headers[j]
            var value = _convert_type(values[j])
            row[key] = value

        result.append(row)

    return result



static func _split_lines(content: String) -> PackedStringArray:

    var normalized = content.replace("\r\n", "\n").replace("\r", "\n")
    return normalized.split("\n")



static func _parse_line(line: String) -> PackedStringArray:
    var result: PackedStringArray = []
    var current = ""
    var in_quotes = false
    var i = 0

    while i < line.length():
        var char = line[i]

        if char == "\"":
            if in_quotes:

                if i + 1 < line.length() and line[i + 1] == "\"":
                    current += "\""
                    i += 1
                else:
                    in_quotes = false
            else:
                in_quotes = true
        elif char == "," and not in_quotes:
            result.append(current.strip_edges())
            current = ""
        else:
            current += char

        i += 1


    result.append(current.strip_edges())

    return result



static func _convert_type(value: String) -> Variant:
    value = value.strip_edges()

    if value.is_empty():
        return ""


    var lower = value.to_lower()
    if lower == "true":
        return true
    if lower == "false":
        return false


    if value.begins_with("[") and value.ends_with("]"):
        var array_result = _parse_array(value)
        if array_result != null:
            return array_result


    if value.begins_with("{") and value.ends_with("}"):
        var dict_result = _parse_dict(value)
        if dict_result != null:
            return dict_result


    if value.is_valid_int():
        return value.to_int()


    if value.is_valid_float():
        return value.to_float()


    return value



static func _parse_array(value: String) -> Variant:

    var json = JSON.new()
    var error = json.parse(value)
    if error == OK:
        var result = json.get_data()
        if result is Array:
            return result


    var inner = value.substr(1, value.length() - 2).strip_edges()
    if inner.is_empty():
        return []

    var result: Array = []
    var items = _split_array_items(inner)

    for item in items:
        result.append(_convert_type(item.strip_edges()))

    return result



static func _split_array_items(content: String) -> PackedStringArray:
    var result: PackedStringArray = []
    var current = ""
    var depth = 0
    var in_quotes = false

    for i in range(content.length()):
        var char = content[i]

        if char == "\"":
            in_quotes = not in_quotes
            current += char
        elif not in_quotes:
            if char == "[" or char == "{":
                depth += 1
                current += char
            elif char == "]" or char == "}":
                depth -= 1
                current += char
            elif char == "," and depth == 0:
                result.append(current.strip_edges())
                current = ""
            else:
                current += char
        else:
            current += char

    if not current.is_empty():
        result.append(current.strip_edges())

    return result



static func _parse_dict(value: String) -> Variant:
    var json = JSON.new()
    var error = json.parse(value)
    if error == OK:
        var result = json.get_data()
        if result is Dictionary:
            return result

    return null



static func array_to_csv(data: Array[Dictionary]) -> String:
    if data.is_empty():
        return ""


    var headers: Array[String] = []
    for row in data:
        for key in row.keys():
            if not headers.has(key):
                headers.append(key)


    var lines: Array[String] = []


    var header_line = ""
    for i in range(headers.size()):
        if i > 0:
            header_line += ","
        header_line += _escape_csv_field(headers[i])
    lines.append(header_line)


    for row in data:
        var line = ""
        for i in range(headers.size()):
            if i > 0:
                line += ","
            var value = row.get(headers[i], "")
            line += _escape_csv_field(_value_to_string(value))
        lines.append(line)

    return "\n".join(lines)



static func _escape_csv_field(field: String) -> String:

    if field.find(",") != -1 or field.find("\"") != -1 or field.find("\n") != -1:

        var escaped = field.replace("\"", "\"\"")
        return "\"" + escaped + "\""
    return field



static func _value_to_string(value: Variant) -> String:
    match typeof(value):
        TYPE_NIL:
            return ""
        TYPE_BOOL:
            return "true" if value else "false"
        TYPE_INT, TYPE_FLOAT:
            return str(value)
        TYPE_ARRAY, TYPE_DICTIONARY:
            return JSON.stringify(value)
        _:
            return str(value)
