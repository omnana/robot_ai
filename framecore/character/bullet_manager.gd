class_name BulletManager
extends Node




const BULLET_SCENE_PATH: = "res://resources/prefabs/bullet/bullet.tscn"


const ENEMY_BULLET_SCENE_PATH: = "res://resources/prefabs/bullet/enemy_bullet.tscn"


const INITIAL_POOL_SIZE: = 20


const MAX_POOL_SIZE: = 500


var _bullet_prefab: PackedScene


var _enemy_bullet_prefab: PackedScene


var _bullet_pool: ObjectPool


var _enemy_bullet_pool: ObjectPool


func _ready() -> void :
    _preload_resources()
    call_deferred("_setup_bullet_pool")



func _preload_resources() -> void :
    _bullet_prefab = preload(BULLET_SCENE_PATH)
    _enemy_bullet_prefab = preload(ENEMY_BULLET_SCENE_PATH)



func _setup_bullet_pool() -> void :
    _bullet_pool = ObjectPool.new()
    _bullet_pool.prefab = _bullet_prefab
    _bullet_pool.initial_size = INITIAL_POOL_SIZE
    _bullet_pool.max_size = MAX_POOL_SIZE
    _bullet_pool.auto_expand = true

    _enemy_bullet_pool = ObjectPool.new()
    _enemy_bullet_pool.prefab = _enemy_bullet_prefab
    _enemy_bullet_pool.initial_size = INITIAL_POOL_SIZE
    _enemy_bullet_pool.max_size = MAX_POOL_SIZE
    _enemy_bullet_pool.auto_expand = true

    var bullet_layer = LayerManager.get_bullet_layer()
    if bullet_layer != null:
        bullet_layer.add_child(_bullet_pool)
        bullet_layer.add_child(_enemy_bullet_pool)
        _bullet_pool.set_spawn_parent(bullet_layer)
        _enemy_bullet_pool.set_spawn_parent(bullet_layer)
    else:
        add_child(_bullet_pool)
        add_child(_enemy_bullet_pool)
        push_warning("[BulletManager] 子弹层未初始化，子弹池添加到本地")







func spawn_bullet(position: Vector2, direction: Vector2, speed: float) -> Bullet:
    var bullet: Bullet = _bullet_pool.acquire()

    if bullet == null:
        push_warning("BulletManager: Failed to spawn bullet, pool exhausted")
        return null


    bullet.set_initial_position(position)
    bullet.set_direction(direction)
    bullet.speed = speed


    if not bullet.request_recycle.is_connected(recycle_bullet):
        bullet.request_recycle.connect(recycle_bullet.bind(bullet))

    return bullet







func spawn_enemy_bullet(position: Vector2, direction: Vector2, speed: float) -> Bullet:
    var bullet: Bullet = _enemy_bullet_pool.acquire()

    if bullet == null:
        push_warning("BulletManager: Failed to spawn enemy bullet, pool exhausted")
        return null


    bullet.set_initial_position(position)
    bullet.set_direction(direction)
    bullet.speed = speed


    if not bullet.request_recycle.is_connected(recycle_enemy_bullet):
        bullet.request_recycle.connect(recycle_enemy_bullet.bind(bullet))

    return bullet




func recycle_bullet(bullet: Bullet) -> void :
    if bullet == null:
        return


    if bullet.request_recycle.is_connected(recycle_bullet):
        bullet.request_recycle.disconnect(recycle_bullet)


    _bullet_pool.release(bullet)




func recycle_enemy_bullet(bullet: Bullet) -> void :
    if bullet == null:
        return


    if bullet.request_recycle.is_connected(recycle_enemy_bullet):
        bullet.request_recycle.disconnect(recycle_enemy_bullet)


    _enemy_bullet_pool.release(bullet)



func get_active_bullet_count() -> int:
    return _bullet_pool.get_active_count()



func get_pooled_bullet_count() -> int:
    return _bullet_pool.get_pooled_count()



func recycle_all_bullets() -> void :
    _bullet_pool.release_all()



func clear_pool() -> void :
    _bullet_pool.clear()
