extends Node


func is_action_pressed(action: StringName) -> bool:
    return Input.is_action_pressed(action)

func is_action_just_pressed(action: StringName) -> bool:
    return Input.is_action_just_pressed(action)

func is_action_just_released(action: StringName) -> bool:
    return Input.is_action_just_released(action)

func get_action_strength(action: StringName) -> float:
    return Input.get_action_strength(action)

func get_axis(negative_action: StringName, positive_action: StringName) -> float:
    return Input.get_axis(negative_action, positive_action)

func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName) -> Vector2:
    return Input.get_vector(negative_x, positive_x, negative_y, positive_y)
