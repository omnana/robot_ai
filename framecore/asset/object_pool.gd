class_name ObjectPool extends Node



signal object_acquired(obj: Node)
signal object_returned(obj: Node)
signal pool_exhausted()

@export var prefab: PackedScene
@export var initial_size: int = 10
@export var max_size: int = 100
@export var auto_expand: bool = true

var _pool: Array[Node] = []
var _active: Array[Node] = []
var _total_created: int = 0
var _spawn_parent: Node = null


func _ready() -> void :
    _spawn_parent = self
    _warm_up()


func set_spawn_parent(parent: Node) -> void :
    _spawn_parent = parent


func _warm_up() -> void :
    for i in initial_size:
        _create_and_pool()


func _create_instance() -> Node:
    if _total_created >= max_size:
        push_warning("ObjectPool: max size (%d) reached" % max_size)
        return null

    var instance: = prefab.instantiate()
    _total_created += 1
    return instance


func _create_and_pool() -> Node:
    var instance: = _create_instance()
    if instance == null:
        return null

    _spawn_parent.add_child(instance)
    _deactivate_object(instance)
    _pool.append(instance)
    return instance


func acquire() -> Node:
    var instance: Node

    if _pool.is_empty():
        if auto_expand:
            instance = _create_instance()
            if instance == null:
                pool_exhausted.emit()
                return null
            _spawn_parent.add_child(instance)
        else:
            pool_exhausted.emit()
            push_warning("ObjectPool: pool exhausted")
            return null
    else:
        instance = _pool.pop_back()

    _activate_object(instance)
    _active.append(instance)
    object_acquired.emit(instance)

    return instance

func release(obj: Node) -> void :
    if obj == null:
        return

    if obj not in _active:
        push_warning("ObjectPool: trying to release object not from this pool")
        return

    _active.erase(obj)
    _deactivate_object(obj)

    if obj.get_parent() != self:
        obj.get_parent().call_deferred("remove_child", obj)
        call_deferred("add_child", obj)

    _pool.append(obj)
    object_returned.emit(obj)

func release_all() -> void :
    for obj in _active.duplicate():
        release(obj)

func _activate_object(obj: Node) -> void :
    obj.set_process(true)
    obj.set_physics_process(true)

    if obj is CanvasItem:
        (obj as CanvasItem).show()

    if obj is CollisionObject2D:
        obj.set_deferred("monitoring", true)
        obj.set_deferred("monitorable", true)

    if obj is CollisionObject3D:
        obj.set_deferred("monitoring", true)
        obj.set_deferred("monitorable", true)

    if obj.has_method("on_acquired_from_pool"):
        obj.on_acquired_from_pool()

func _deactivate_object(obj: Node) -> void :
    obj.set_process(false)
    obj.set_physics_process(false)

    if obj is CollisionObject2D:
        obj.set_deferred("monitoring", false)
        obj.set_deferred("monitorable", false)

    if obj is CollisionObject3D:
        obj.set_deferred("monitoring", false)
        obj.set_deferred("monitorable", false)

    if obj is RigidBody2D:
        obj.linear_velocity = Vector2.ZERO
        obj.angular_velocity = 0.0

    if obj is RigidBody3D:
        obj.linear_velocity = Vector3.ZERO
        obj.angular_velocity = Vector3.ZERO

    if obj.has_method("on_returned_to_pool"):
        obj.on_returned_to_pool()

    _reset_object_state(obj)

    if obj is CanvasItem:
        (obj as CanvasItem).hide()

func _reset_object_state(obj: Node) -> void :
    if obj is Node2D:
        obj.position = Vector2.ZERO
        obj.rotation = 0.0
        obj.scale = Vector2.ONE

    if obj is Node3D:
        obj.position = Vector3.ZERO
        obj.rotation = Vector3.ZERO
        obj.scale = Vector3.ONE

    if obj.has_method("reset_state"):
        obj.reset_state()

func get_active_count() -> int:
    return _active.size()

func get_pooled_count() -> int:
    return _pool.size()

func get_total_created() -> int:
    return _total_created

func clear() -> void :
    for obj in _pool:
        obj.queue_free()
    for obj in _active:
        obj.queue_free()
    _pool.clear()
    _active.clear()
    _total_created = 0

func prewarm(count: int) -> void :
    for i in count:
        _create_and_pool()
