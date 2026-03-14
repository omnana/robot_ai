







class_name AngryBull
extends Boss



enum AttackType{
    SIMPLE_DASH, 
    STOMP_ATTACK, 
}




var dash_direction: Vector2 = Vector2.ZERO


var is_dashing: bool = false


var bounce_remaining: int = 0


var animated_sprite: AnimatedSprite2D = null


var warning_line: Line2D = null


var hit_area: Area2D = null


var current_state_name: String = ""


var telegraph_timer: float = 0.0


var is_direction_locked: bool = false


var idle_timer: float = 0.0


var stun_timer: float = 0.0


var bullet_manager: BulletManager = null


var _trail_timer: float = 0.0


var _camera: Camera2D = null


var _original_camera_offset: Vector2 = Vector2.ZERO


var _current_attack_type: int = AttackType.SIMPLE_DASH


var _current_dash_distance: float = 600.0


var _dashed_distance: float = 0.0


var _enrage_animation_done: bool = false


var _dance_audio: AudioStreamPlayer = null


var _angry_audio_played: bool = false


## 分裂召唤系统
var is_minion: bool = false
var _parent_boss: Node = null
var _target_scale: Vector2 = Vector2.ONE
var _summon_timer: float = 0.0
var _summon_interval: float = 15.0
var _is_split: bool = false
var _minions: Array = []
var _battle_active: bool = false
var _split_wave: int = 0  # 分裂波次计数


func _ready() -> void :
    super._ready()


    visible = false
    scale = Vector2.ZERO


    animated_sprite = get_node_or_null("AnimatedSprite2D")
    if animated_sprite == null:
        push_warning("[AngryBull] 未找到 AnimatedSprite2D 节点")


    _setup_camera()


    _setup_bullet_manager()


    _create_warning_line()


    _create_hit_area()


    _setup_audio_players()


    _connect_state_signals()

    if state_chart != null:
        state_chart.process_mode = Node.PROCESS_MODE_DISABLED



func start_battle() -> void :
    print("[AngryBull] start_battle() 被调用")
    visible = true
    _animate_spawn()



func _animate_spawn() -> void :
    print("[AngryBull] _animate_spawn() 开始")
    scale = Vector2.ZERO

    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_ELASTIC)

    tween.tween_property(self, "scale", _target_scale, 0.2)
    tween.tween_callback(_on_spawn_animation_finished)



func _on_spawn_animation_finished() -> void :
    print("[AngryBull] _on_spawn_animation_finished() 出场动画完成")
    _battle_active = true

    if state_chart != null:
        state_chart.process_mode = Node.PROCESS_MODE_INHERIT
        state_chart.send_event(&"battle_start")
    print("[AngryBull] Boss战开始!")


func init_from_config(id: String) -> void :
    super.init_from_config(id)




func _connect_state_signals() -> void :
    if state_chart == null:
        push_warning("[AngryBull] 状态机未初始化，无法连接信号")
        return


    _connect_state_signal("BossBehavior/Phase1/Idle", "state_entered", _on_idle_entered)
    _connect_state_signal("BossBehavior/Phase1/Telegraphing", "state_entered", _on_telegraphing_entered)
    _connect_state_signal("BossBehavior/Phase1/Dashing", "state_entered", _on_dashing_entered)
    _connect_state_signal("BossBehavior/Phase1/DashComplete", "state_entered", _on_dash_complete_entered)
    _connect_state_signal("BossBehavior/Phase1/Falling", "state_entered", _on_falling_entered)
    _connect_state_signal("BossBehavior/Phase1/Stun", "state_entered", _on_stun_entered)


    _connect_state_signal("BossBehavior/Phase2/EnragedEntry", "state_entered", _on_enraged_entered)
    _connect_state_signal("BossBehavior/Phase2/Idle", "state_entered", _on_idle_entered)
    _connect_state_signal("BossBehavior/Phase2/Telegraphing", "state_entered", _on_telegraphing_entered)
    _connect_state_signal("BossBehavior/Phase2/Dashing", "state_entered", _on_dashing_entered)
    _connect_state_signal("BossBehavior/Phase2/DashComplete", "state_entered", _on_dash_complete_entered)
    _connect_state_signal("BossBehavior/Phase2/Falling", "state_entered", _on_falling_entered)
    _connect_state_signal("BossBehavior/Phase2/Stun", "state_entered", _on_stun_entered)


    _connect_state_signal("BossBehavior/Dead", "state_entered", _on_dead_entered)






func _connect_state_signal(state_path: String, signal_name: String, callback: Callable) -> void :
    var state_node = state_chart.get_node_or_null(state_path)
    if state_node == null:
        push_warning("[AngryBull] 未找到状态节点: " + state_path)
        return

    if not state_node.has_signal(signal_name):
        push_warning("[AngryBull] 状态节点没有信号: " + state_path + "/" + signal_name)
        return

    state_node.connect(signal_name, callback)




func _on_idle_entered() -> void :
    print("[AngryBull] 进入Idle状态")
    current_state_name = "Idle"


    is_dashing = false
    dash_direction = Vector2.ZERO


    bounce_remaining = bounce_count


    idle_timer = 0.0


    _play_animation("idle")



func _on_telegraphing_entered() -> void :
    print("[AngryBull] 进入Telegraphing状态")
    current_state_name = "Telegraphing"


    telegraph_timer = 0.0


    is_direction_locked = false


    _select_random_attack_type()

    _dashed_distance = 0.0


    if warning_line != null:
        warning_line.visible = true


    _play_animation("telegraphing")



func _on_dashing_entered() -> void :
    print("[AngryBull] 进入Dashing状态")
    current_state_name = "Dashing"


    is_dashing = true


    if hit_area != null:
        hit_area.monitoring = true


    if not is_direction_locked:
        dash_direction = get_direction_to_target()


        if dash_direction == Vector2.ZERO:
            dash_direction = Vector2.RIGHT.rotated(randf() * TAU)


    _update_facing(dash_direction)


    _hide_warning_line()


    collision_mask = LayerConstants.COLLISION_OBSTACLE
    print("[AngryBull] 冲刺 collision_mask 设置为: ", collision_mask, " (只检测障碍物)")


    _play_animation("dash")



func _on_falling_entered() -> void :
    print("[AngryBull] 进入Falling状态")
    current_state_name = "Falling"


    is_dashing = false


    collision_mask = LayerConstants.COLLISION_PLAYER | LayerConstants.COLLISION_OBSTACLE


    _hide_warning_line()


    _play_animation("falling")



func _on_stun_entered() -> void :
    print("[AngryBull] 进入Stun状态")
    current_state_name = "Stun"


    stun_timer = 0.0


    _play_animation("stun")



func _on_dash_complete_entered() -> void :
    print("[AngryBull] 进入DashComplete状态，攻击类型: ", _current_attack_type)
    current_state_name = "DashComplete"


    collision_mask = LayerConstants.COLLISION_PLAYER | LayerConstants.COLLISION_OBSTACLE


    _play_animation("idle")


    match _current_attack_type:
        AttackType.STOMP_ATTACK:
            _execute_stomp_attack()
        _:

            await get_tree().create_timer(0.3).timeout
            if state_chart != null:
                state_chart.send_event(&"dash_done")



func _select_random_attack_type() -> void :
    var attack_types = [AttackType.SIMPLE_DASH, AttackType.SIMPLE_DASH, AttackType.STOMP_ATTACK]
    _current_attack_type = attack_types[randi() % attack_types.size()]
    print("[AngryBull] 选择攻击类型: ", _current_attack_type)



func _execute_stomp_attack() -> void :
    print("[AngryBull] 执行踩踏攻击")

    _play_animation("attack")


    _play_dance_music()


    _create_stomp_effect()


    if hit_area != null:
        hit_area.monitoring = true


    await get_tree().physics_frame


    _check_player_collision(true)


    var bullet_wave_count = 4
    var bullet_interval = 37.0 / 12.0 / bullet_wave_count
    var angle_offset = 0.0
    var angle_step = TAU / 8.0

    for wave in range(bullet_wave_count):
        _fire_stomp_bullets(angle_offset)
        angle_offset += angle_step / 3.0
        await get_tree().create_timer(bullet_interval).timeout


    _remove_stomp_effect()

    if state_chart != null:
        state_chart.send_event(&"dash_done")



func _create_stomp_effect() -> void :

    var stomp_sprite = Sprite2D.new()
    stomp_sprite.name = "StompEffect"
    var texture = AssetManager.load("res://resources/sprites/map/img_fw.png")
    if texture != null:
        stomp_sprite.texture = texture
    stomp_sprite.z_index = LayerConstants.Z_FLOOR + 1


    stomp_sprite.position = Vector2(0, 50)


    var texture_size = stomp_sprite.texture.get_size()
    var target_size = Vector2(300, 300)
    stomp_sprite.scale = target_size / texture_size

    add_child(stomp_sprite)
    print("[AngryBull] 创建脚底踩踏特效")



func _remove_stomp_effect() -> void :
    var stomp_sprite = get_node_or_null("StompEffect")
    if stomp_sprite != null:
        stomp_sprite.queue_free()
        print("[AngryBull] 移除脚底踩踏特效")




func _fire_stomp_bullets(angle_offset: float) -> void :
    if bullet_manager == null:
        print("[AngryBull] 弹幕管理器未初始化")
        return

    var count = 8
    if is_enraged:
        count = 12

    print("[AngryBull] 踩踏发射弹幕，数量: ", count, " 角度偏移: ", angle_offset)

    var bullet_texture = AssetManager.load("res://resources/sprites/map/img_zd2.png")
    var angle_step = TAU / count

    if bullet_texture != null:
        for i in range(count):
            var angle = i * angle_step + angle_offset
            var direction = Vector2.RIGHT.rotated(angle)

            var bullet = bullet_manager.spawn_enemy_bullet(global_position, direction, 200.0)
            if bullet != null:
                bullet.damage = damage / 2


                bullet.scale = Vector2(2, 2)

                if bullet.sprite != null:
                    bullet.sprite.texture = bullet_texture



func _on_enraged_entered() -> void :
    print("[AngryBull] 进入EnragedEntry状态")
    current_state_name = "EnragedEntry"


    _enrage_animation_done = false
    _angry_audio_played = false


    _play_animation("angry1")


    if animated_sprite and animated_sprite.animation_finished.is_connected(_on_angry1_finished):
        animated_sprite.animation_finished.disconnect(_on_angry1_finished)
    animated_sprite.animation_finished.connect(_on_angry1_finished)



func _on_angry1_finished() -> void :
    if _enrage_animation_done:
        return
    _enrage_animation_done = true


    if not _angry_audio_played:
        _angry_audio_played = true
        AudioManager.play_se("res://resources/audios/sfx/boss/boss_angry.mp3")


    _play_animation("angry2")


    await get_tree().create_timer(2.0).timeout
    if state_chart != null:
        state_chart.send_event(&"enrage_done")



func _on_dead_entered() -> void :
    print("[AngryBull] 进入死亡状态")
    current_state_name = "Dead"


    if animated_sprite != null and animated_sprite.sprite_frames != null:
        if animated_sprite.sprite_frames.has_animation("die"):
            animated_sprite.play("die")
        elif animated_sprite.sprite_frames.has_animation("stun"):
            animated_sprite.play("stun")



func _physics_process(delta: float) -> void :
    if _is_split:
        return

    # 小弟边界钳制：防止跑到竞技场外面
    if is_minion:
        var controllers = get_tree().get_nodes_in_group("boss_battle_controller")
        if not controllers.is_empty():
            var arena = controllers[0].get("_arena")
            if arena != null and arena.has_method("get_bounds"):
                var b: Rect2 = arena.get_bounds()
                var m = 30.0
                global_position.x = clampf(global_position.x, b.position.x + m, b.end.x - m)
                global_position.y = clampf(global_position.y, b.position.y + m, b.end.y - m)

    match current_state_name:
        "Idle":
            _process_idle_state(delta)
        "Telegraphing":
            _process_telegraphing_state(delta)
        "Dashing":
            _process_dashing_state(delta)
        "Falling":
            _process_falling_state(delta)
        "Stun":
            _process_stun_state(delta)
        "EnragedEntry":
            _process_enraged_entry_state(delta)

    # 分裂召唤计时
    if _battle_active and not is_minion and not _is_split:
        _summon_timer += delta
        if _summon_timer >= _summon_interval:
            _start_split()




func _process_idle_state(delta: float) -> void :

    velocity = Vector2.ZERO


    idle_timer += delta




func _process_telegraphing_state(delta: float) -> void :

    velocity = Vector2.ZERO


    telegraph_timer += delta


    _update_warning_line()


    if not is_direction_locked:
        var direction_to_target = get_direction_to_target()
        if direction_to_target != Vector2.ZERO:
            dash_direction = direction_to_target
            _update_facing(dash_direction)




func _process_dashing_state(delta: float) -> void :

    _perform_dash(delta)




func _process_falling_state(delta: float) -> void :

    velocity = Vector2.ZERO




func _process_stun_state(delta: float) -> void :

    velocity = Vector2.ZERO




func _process_enraged_entry_state(delta: float) -> void :

    velocity = Vector2.ZERO




func _perform_dash(delta: float) -> void :

    var speed = dash_speed
    if is_enraged:
        speed *= phase2_speed_multiplier


    var motion = dash_direction * speed * delta
    _dashed_distance += motion.length()


    if _dashed_distance >= _current_dash_distance:

        velocity = Vector2.ZERO
        if state_chart != null:
            state_chart.send_event(&"dash_complete")
        return


    var collision = move_and_collide(motion)

    if collision != null:

        if state_chart != null:
            state_chart.send_event(&"hit_wall")


        _handle_bounce(collision)


    if is_enraged:
        _spawn_dash_trail(delta)


    _check_player_collision()




func _check_player_collision(disable_after: bool = false) -> void :
    if hit_area == null:
        return


    if not hit_area.monitoring:
        return

    var bodies = hit_area.get_overlapping_bodies()
    for body in bodies:
        if body.is_in_group("player"):
            if body.has_method("take_damage"):
                body.take_damage(damage)
                print("[AngryBull] 冲锋对玩家造成伤害: ", damage)

                hit_area.monitoring = false
                return


    if disable_after:
        hit_area.monitoring = false




func _handle_bounce(collision: KinematicCollision2D) -> void :

    bounce_remaining -= 1


    if is_enraged:
        _spawn_wall_bullets(global_position)


    if bounce_remaining > 0:

        var normal = collision.get_normal()
        dash_direction = dash_direction.bounce(normal)


        _update_facing(dash_direction)

        print("[AngryBull] 反弹，剩余次数: " + str(bounce_remaining))
    else:

        print("[AngryBull] 反弹次数用尽，进入眩晕")




func _create_warning_line() -> void :
    warning_line = Line2D.new()
    warning_line.name = "WarningLine"
    warning_line.width = 90
    warning_line.default_color = Color(1.0, 0.0, 0.0, 0.5)
    warning_line.visible = false
    warning_line.z_index = LayerConstants.Z_BACKGROUND
    warning_line.top_level = true
    add_child(warning_line)



func _hide_warning_line() -> void :
    if warning_line == null:
        return
    warning_line.visible = false
    warning_line.clear_points()



func _create_hit_area() -> void :
    hit_area = Area2D.new()
    hit_area.name = "HitArea"
    hit_area.monitoring = true
    hit_area.monitorable = true

    var collision_shape = CollisionShape2D.new()
    collision_shape.name = "CollisionShape2D"
    var shape = RectangleShape2D.new()
    shape.size = Vector2(100, 100)
    collision_shape.shape = shape
    hit_area.add_child(collision_shape)

    hit_area.collision_layer = 0
    hit_area.collision_mask = LayerConstants.COLLISION_PLAYER

    hit_area.body_entered.connect(_on_hit_area_body_entered)

    add_child(hit_area)
    print("[AngryBull] 碰撞检测区域创建完成, collision_mask: ", hit_area.collision_mask)



func _update_warning_line() -> void :
    if warning_line == null or not warning_line.visible:
        return


    warning_line.clear_points()


    var start_pos = global_position
    warning_line.add_point(start_pos)


    var line_length = 800.0
    var end_pos = start_pos + dash_direction * line_length
    warning_line.add_point(end_pos)




func _play_animation(anim_name: String) -> void :
    if animated_sprite == null:
        return

    if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(anim_name):
        animated_sprite.play(anim_name)
    else:
        push_warning("[AngryBull] 动画不存在: " + anim_name)



func _update_facing(direction: Vector2) -> void :
    if animated_sprite == null:
        return


    if direction.x < 0:
        animated_sprite.flip_h = true
    elif direction.x > 0:
        animated_sprite.flip_h = false



func _setup_camera() -> void :

    var cameras = get_tree().get_nodes_in_group("camera")
    if cameras.size() > 0:
        _camera = cameras[0]
        _original_camera_offset = _camera.offset
        print("[AngryBull] 找到摄像机")
    else:

        var players = get_tree().get_nodes_in_group("player")
        if players.size() > 0:
            var player = players[0]
            _camera = player.get_node_or_null("Camera2D")
            if _camera != null:
                _original_camera_offset = _camera.offset
                print("[AngryBull] 从玩家获取摄像机")



func _setup_bullet_manager() -> void :

    var bullet_managers = get_tree().get_nodes_in_group("bullet_manager")
    if bullet_managers.size() > 0:
        bullet_manager = bullet_managers[0]
        print("[AngryBull] 找到子弹管理器")
    else:

        var players = get_tree().get_nodes_in_group("player")
        if players.size() > 0:
            var player = players[0]
            bullet_manager = player.get_node_or_null("BulletManager")
            if bullet_manager != null:
                print("[AngryBull] 从玩家获取子弹管理器")



func _setup_audio_players() -> void :
    _dance_audio = AudioStreamPlayer.new()
    _dance_audio.name = "DanceAudio"
    _dance_audio.bus = &"Master"
    add_child(_dance_audio)
    print("[AngryBull] 音效播放器创建完成")



func _spawn_dash_trail(delta: float) -> void :
    _trail_timer += delta

    var trail_interval = 0.05
    if _trail_timer >= trail_interval:
        _trail_timer = 0.0

        EffectManager.spawn("dash_trail", {
            "position": global_position, 
            "duration": trail_duration, 
            "z_index": LayerConstants.Z_BACKGROUND
        })



func _spawn_wall_bullets(pos: Vector2) -> void :
    if bullet_manager == null:
        return

    var count = bullet_count
    var angle_step = TAU / count

    for i in range(count):
        var angle = i * angle_step
        var direction = Vector2.RIGHT.rotated(angle)

        var bullet = bullet_manager.spawn_enemy_bullet(pos, direction, 300.0)
        if bullet != null:
            bullet.damage = damage / 2

            bullet.scale = Vector2(2, 2)



func _on_hit_area_body_entered(body: Node2D) -> void :
    print("[AngryBull] 检测到碰撞: ", body.name, " groups: ", body.get_groups())
    if body.is_in_group("player"):
        print("[AngryBull] 玩家进入碰撞区域")

        if body.has_method("take_damage"):
            body.take_damage(damage)
            print("[AngryBull] 对玩家造成伤害: ", damage)



func die() -> void :
    _battle_active = false

    # 清理所有小弟
    for minion in _minions:
        if is_instance_valid(minion):
            minion.queue_free()
    _minions.clear()
    _is_split = false

    super.die()

    # 从敌人组移除，防止追踪弹和AI继续攻击死亡单位
    remove_from_group("enemy")

    if warning_line != null:
        warning_line.visible = false


    if animated_sprite != null:
        if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("die"):
            animated_sprite.play("die")
            animated_sprite.animation_finished.connect(_on_death_animation_finished)
        elif animated_sprite.sprite_frames.has_animation("stun"):
            animated_sprite.play("stun")
            animated_sprite.animation_finished.connect(_on_death_animation_finished)
        else:
            # 没有死亡动画，直接延迟释放
            _on_death_animation_finished()


    set_deferred("collision_layer", 0)
    set_deferred("collision_mask", 0)

    if hit_area != null:
        hit_area.set_deferred("monitoring", false)
        hit_area.set_deferred("monitorable", false)


func _on_death_animation_finished() -> void :
    if animated_sprite != null:
        animated_sprite.pause()
        animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("die") - 1


    _stop_dance_music()

    await get_tree().create_timer(1.0).timeout
    queue_free()



func _play_dance_music() -> void :
    if _dance_audio == null:
        return

    var music = AssetManager.load("res://resources/audios/sfx/boss/boss_dance.mp3")
    if music != null:
        return

    _dance_audio.stream = music
    _dance_audio.volume_db = 0.0
    _dance_audio.play()
    print("[AngryBull] 开始播放踩踏音效")



func _stop_dance_music() -> void :
    if _dance_audio == null:
        return

    if _dance_audio.playing:
        _dance_audio.stop()
        print("[AngryBull] 停止踩踏音效")



# ========== 分裂召唤系统 ==========


func _start_split() -> void :
    print("[AngryBull] 开始分裂，召唤5个小弟")
    _is_split = true
    _summon_timer = 0.0

    # 停止当前行为
    is_dashing = false
    dash_direction = Vector2.ZERO
    velocity = Vector2.ZERO
    _hide_warning_line()
    _stop_dance_music()

    # 隐藏Boss
    visible = false
    set_deferred("collision_layer", 0)
    set_deferred("collision_mask", 0)
    if hit_area != null:
        hit_area.monitoring = false
    if state_chart != null:
        state_chart.process_mode = Node.PROCESS_MODE_DISABLED

    # 生成5个小弟
    var boss_scene = load("res://resources/prefabs/boss/angry_bull.tscn")
    var positions = _get_minion_spawn_positions()

    for i in range(5):
        var minion = boss_scene.instantiate()
        minion.is_minion = true
        minion._parent_boss = self
        minion._target_scale = Vector2(0.4, 0.4)

        get_parent().add_child(minion)
        minion.global_position = positions[i]

        # 从配置初始化并缩小属性
        minion.init_from_config("angry_bull")
        # 小弟血量：第1波=100，之后每波*1.5，上限boss的1/2
        var base_minion_hp = 100.0
        var wave_hp = base_minion_hp * pow(1.5, _split_wave)
        var max_minion_hp = max_hp / 2.0
        minion.max_hp = maxi(1, int(minf(wave_hp, max_minion_hp)))
        minion.current_hp = minion.max_hp
        minion.damage = maxi(1, damage / 2)
        minion.dash_speed = dash_speed * 0.8

        if target != null and is_instance_valid(target):
            minion.set_target(target)

        minion.died.connect(_on_minion_died.bind(minion))
        minion.start_battle()

        _minions.append(minion)

    _split_wave += 1
    print("[AngryBull] 第", _split_wave, "波小弟已召唤，血量: ", _minions[0].max_hp if _minions.size() > 0 else 0)


func _get_minion_spawn_positions() -> Array:
    var positions: Array = []
    var radius = 150.0
    # 获取竞技场边界，确保小弟不会生成在外面
    var bounds: Rect2 = Rect2()
    var has_bounds = false
    var controllers = get_tree().get_nodes_in_group("boss_battle_controller")
    if not controllers.is_empty():
        var arena = controllers[0].get("_arena")
        if arena != null and arena.has_method("get_bounds"):
            bounds = arena.get_bounds()
            has_bounds = true
    var margin = 80.0
    for i in range(5):
        var angle = i * TAU / 5.0
        var pos = global_position + Vector2.RIGHT.rotated(angle) * radius
        if has_bounds:
            pos.x = clampf(pos.x, bounds.position.x + margin, bounds.end.x - margin)
            pos.y = clampf(pos.y, bounds.position.y + margin, bounds.end.y - margin)
        positions.append(pos)
    return positions


func _on_minion_died(minion: Node) -> void :
    if minion in _minions:
        _minions.erase(minion)

    # 给玩家随机Buff
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        var player = players[0]
        if player.buff_manager != null:
            player.buff_manager.grant_random_buff()

    print("[AngryBull] 小弟被击杀，剩余: ", _minions.size())
    if _minions.is_empty() and _is_split:
        _on_all_minions_died()


func _on_all_minions_died() -> void :
    print("[AngryBull] 所有小弟已被消灭，Boss恢复")
    _is_split = false

    # Boss重新出现动画
    visible = true
    scale = Vector2.ZERO
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_ELASTIC)
    tween.tween_property(self, "scale", Vector2.ONE, 0.2)
    tween.tween_callback(_on_boss_restored)


func _on_boss_restored() -> void :
    print("[AngryBull] Boss恢复完成")
    # 恢复碰撞
    collision_layer = LayerConstants.COLLISION_ENEMY
    collision_mask = LayerConstants.COLLISION_PLAYER | LayerConstants.COLLISION_OBSTACLE

    # 恢复状态机
    if state_chart != null:
        state_chart.process_mode = Node.PROCESS_MODE_INHERIT

    # 重置召唤计时器
    _summon_timer = 0.0
