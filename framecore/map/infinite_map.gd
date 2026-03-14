class_name InfiniteMap extends Node2D


@export var tile_size: Vector2 = Vector2(512, 512)
@export var chunk_size: int = 3
@export var background_texture: Texture2D

var _camera: Camera2D
var _loaded_chunks: Dictionary = {}
var _chunk_offsets: Dictionary = {}

func _ready() -> void :
    z_index = LayerConstants.Z_FLOOR
    _setup_camera()
    if background_texture:
        _generate_initial_chunks()

func _setup_camera() -> void :
    var parent = get_parent()
    if parent and parent is CanvasItem:
        _camera = parent.get_viewport().get_camera_2d()
    else:
        _camera = get_viewport().get_camera_2d()

func _process(_delta: float) -> void :
    if _camera:
        _update_chunks()

func _generate_initial_chunks() -> void :
    if not _camera:
        return
    var camera_pos = _camera.get_global_position()
    var center_chunk = _world_to_chunk(camera_pos)
    for x in range(center_chunk.x - chunk_size, center_chunk.x + chunk_size + 1):
        for y in range(center_chunk.y - chunk_size, center_chunk.y + chunk_size + 1):
            _load_chunk(Vector2i(x, y))

func _update_chunks() -> void :
    if not _camera:
        return
    var camera_pos = _camera.get_global_position()
    var center_chunk = _world_to_chunk(camera_pos)

    var needed_chunks: Array[Vector2i] = []
    for x in range(center_chunk.x - chunk_size, center_chunk.x + chunk_size + 1):
        for y in range(center_chunk.y - chunk_size, center_chunk.y + chunk_size + 1):
            needed_chunks.append(Vector2i(x, y))

    var chunks_to_remove: Array[Vector2i] = []
    for chunk_pos in _loaded_chunks.keys():
        if not chunk_pos in needed_chunks:
            chunks_to_remove.append(chunk_pos)

    for chunk_pos in chunks_to_remove:
        _unload_chunk(chunk_pos)

    for chunk_pos in needed_chunks:
        if not _loaded_chunks.has(chunk_pos):
            _load_chunk(chunk_pos)

func _world_to_chunk(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(floor(world_pos.x / tile_size.x)), 
        int(floor(world_pos.y / tile_size.y))
    )

func _load_chunk(chunk_pos: Vector2i) -> void :
    var world_pos = _chunk_to_world(chunk_pos)
    var sprite = Sprite2D.new()
    sprite.texture = background_texture
    sprite.position = world_pos
    sprite.scale = Vector2(
        tile_size.x / background_texture.get_width(), 
        tile_size.y / background_texture.get_height()
    )
    _loaded_chunks[chunk_pos] = sprite
    add_child(sprite)

func _unload_chunk(chunk_pos: Vector2i) -> void :
    if _loaded_chunks.has(chunk_pos):
        var sprite = _loaded_chunks[chunk_pos]
        sprite.queue_free()
        _loaded_chunks.erase(chunk_pos)

func _chunk_to_world(chunk_pos: Vector2i) -> Vector2:
    return Vector2(
        chunk_pos.x * tile_size.x, 
        chunk_pos.y * tile_size.y
    )

func set_background(texture: Texture2D) -> void :
    background_texture = texture
    _clear_all_chunks()
    _generate_initial_chunks()

func _clear_all_chunks() -> void :
    for sprite in _loaded_chunks.values():
        sprite.queue_free()
    _loaded_chunks.clear()
