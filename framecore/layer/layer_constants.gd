






class_name LayerConstants



const Z_FLOOR: int = -20
const Z_BACKGROUND: int = -10
const Z_WARNING_EFFECT: int = -8
const Z_WALL: int = -5
const Z_WARNING: int = 0
const Z_CHARACTER: int = 5
const Z_BULLET: int = 10
const Z_EFFECT: int = 15
const Z_UI: int = 100



const COLLISION_PLAYER: int = 1
const COLLISION_ENEMY: int = 2
const COLLISION_PLAYER_BULLET: int = 4
const COLLISION_ENEMY_BULLET: int = 8
const COLLISION_OBSTACLE: int = 16
const COLLISION_TRIGGER: int = 32



static func get_player_collision() -> Dictionary:
    return {
        "layer": COLLISION_PLAYER, 
        "mask": COLLISION_ENEMY | COLLISION_ENEMY_BULLET | COLLISION_OBSTACLE
    }


static func get_enemy_collision() -> Dictionary:
    return {
        "layer": COLLISION_ENEMY, 
        "mask": COLLISION_PLAYER | COLLISION_PLAYER_BULLET | COLLISION_OBSTACLE
    }


static func get_player_bullet_collision() -> Dictionary:
    return {
        "layer": COLLISION_PLAYER_BULLET, 
        "mask": COLLISION_ENEMY | COLLISION_OBSTACLE
    }


static func get_enemy_bullet_collision() -> Dictionary:
    return {
        "layer": COLLISION_ENEMY_BULLET, 
        "mask": COLLISION_PLAYER | COLLISION_OBSTACLE
    }


static func get_obstacle_collision() -> Dictionary:
    return {
        "layer": COLLISION_OBSTACLE, 
        "mask": COLLISION_PLAYER | COLLISION_ENEMY | COLLISION_PLAYER_BULLET | COLLISION_ENEMY_BULLET
    }


static func get_trigger_collision() -> Dictionary:
    return {
        "layer": COLLISION_TRIGGER, 
        "mask": COLLISION_PLAYER
    }



static func apply_collision_to_node(node: CollisionObject2D, config: Dictionary) -> void :
    if config.has("layer"):
        node.collision_layer = config["layer"]
    if config.has("mask"):
        node.collision_mask = config["mask"]
