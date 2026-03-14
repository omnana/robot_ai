

class_name BattleArena
extends Node2D


signal arena_created()

signal arena_destroyed()


@export var arena_size: Vector2 = Vector2(1600, 1200)

@export var wall_thickness: float = 61.0

@export var fade_duration: float = 0.5


var _walls_container: Node2D = null

var _walls: Array[StaticBody2D] = []

var _wall_visuals: Array[Node2D] = []

var _wall_collisions: Array[CollisionShape2D] = []

var _locked_camera: Camera2D = null

var _center: Vector2 = Vector2.ZERO

var _is_created: bool = false

var _fade_tween: Tween = null


func _ready() -> void :
    _walls_container = Node2D.new()
    _walls_container.name = "WallsContainer"
    _walls_container.z_index = LayerConstants.Z_WALL
    add_child(_walls_container)



func create_arena(center: Vector2) -> void :
    if _is_created:
        push_warning("BattleArena: 围墙已存在，请先销毁再创建")
        return

    _center = center
    _is_created = true


    _create_walls()


    _fade_in()



func destroy_arena() -> void :
    if not _is_created:
        push_warning("BattleArena: 围墙不存在")
        return


    _fade_out()



func get_bounds() -> Rect2:
    var half_size = arena_size / 2.0
    return Rect2(
        _center - half_size, 
        arena_size
    )



func lock_camera(camera: Camera2D) -> void :
    if camera == null:
        push_warning("BattleArena: 摄像机为空")
        return

    _locked_camera = camera


    var bounds = get_bounds()
    camera.limit_left = bounds.position.x
    camera.limit_top = bounds.position.y
    camera.limit_right = bounds.end.x
    camera.limit_bottom = bounds.end.y



func unlock_camera() -> void :
    if _locked_camera == null:
        return


    _locked_camera.limit_left = -10000000
    _locked_camera.limit_top = -10000000
    _locked_camera.limit_right = 10000000
    _locked_camera.limit_bottom = 10000000

    _locked_camera = null



func _create_walls() -> void :

    _clear_walls()

    var half_width = arena_size.x / 2.0
    var half_height = arena_size.y / 2.0


    var wall_configs: Array[Dictionary] = [

        {
            "offset": Vector2(0, - half_height - wall_thickness / 2.0), 
            "size": Vector2(arena_size.x + wall_thickness * 2.0, wall_thickness)
        }, 

        {
            "offset": Vector2(0, half_height + wall_thickness / 2.0), 
            "size": Vector2(arena_size.x + wall_thickness * 2.0, wall_thickness)
        }, 

        {
            "offset": Vector2( - half_width - wall_thickness / 2.0, 0), 
            "size": Vector2(wall_thickness, arena_size.y)
        }, 

        {
            "offset": Vector2(half_width + wall_thickness / 2.0, 0), 
            "size": Vector2(wall_thickness, arena_size.y)
        }
    ]

    for i in range(wall_configs.size()):
        var config = wall_configs[i]
        var wall = _create_single_wall(i, config["offset"], config["size"])
        _walls.append(wall)



func _create_single_wall(index: int, offset: Vector2, size: Vector2) -> StaticBody2D:
    var wall = StaticBody2D.new()
    wall.name = "Wall_%d" % index
    wall.position = _center + offset

    var collision_config = LayerConstants.get_obstacle_collision()
    LayerConstants.apply_collision_to_node(wall, collision_config)

    _walls_container.add_child(wall)


    var collision = CollisionShape2D.new()
    collision.name = "CollisionShape2D"
    var shape = RectangleShape2D.new()
    shape.size = size
    collision.shape = shape
    wall.add_child(collision)
    _wall_collisions.append(collision)


    var texture = preload("res://resources/sprites/map/img_zhauntou.png")
    var actual_texture_size = Vector2(61.0, 63.0)
    var visuals_container = Node2D.new()
    visuals_container.name = "VisualsContainer"
    visuals_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
    wall.add_child(visuals_container)


    var tiles_x = ceili(size.x / actual_texture_size.x)
    var tiles_y = ceili(size.y / actual_texture_size.y)
    var start_pos = Vector2( - size.x / 2.0, - size.y / 2.0)

    for tx in range(tiles_x):
        for ty in range(tiles_y):
            var visual = Sprite2D.new()
            visual.texture = texture
            visual.centered = false
            var tile_pos = start_pos + Vector2(tx * actual_texture_size.x, ty * actual_texture_size.y)

            var remaining_x = size.x - tx * actual_texture_size.x
            var remaining_y = size.y - ty * actual_texture_size.y
            visual.region_enabled = true
            visual.region_rect = Rect2(0, 0, minf(remaining_x, actual_texture_size.x), minf(remaining_y, actual_texture_size.y))
            visual.position = tile_pos
            visuals_container.add_child(visual)

    _wall_visuals.append(visuals_container)

    return wall



func _clear_walls() -> void :
    for wall in _walls:
        if is_instance_valid(wall):
            wall.queue_free()

    _walls.clear()
    _wall_visuals.clear()
    _wall_collisions.clear()



func _fade_in() -> void :

    if _fade_tween and _fade_tween.is_valid():
        _fade_tween.kill()

    _fade_tween = create_tween()
    _fade_tween.set_parallel(true)

    for visual in _wall_visuals:
        _fade_tween.tween_property(visual, "modulate:a", 1.0, fade_duration)

    _fade_tween.set_parallel(false)
    _fade_tween.tween_callback(_on_fade_in_complete)



func _fade_out() -> void :

    if _fade_tween and _fade_tween.is_valid():
        _fade_tween.kill()

    _fade_tween = create_tween()
    _fade_tween.set_parallel(true)

    for visual in _wall_visuals:
        _fade_tween.tween_property(visual, "modulate:a", 0.0, fade_duration)

    _fade_tween.set_parallel(false)
    _fade_tween.tween_callback(_on_fade_out_complete)



func _on_fade_in_complete() -> void :
    arena_created.emit()



func _on_fade_out_complete() -> void :
    _is_created = false
    _clear_walls()
    arena_destroyed.emit()
