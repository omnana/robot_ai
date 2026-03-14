extends Node


enum State{
    NONE, 
    LOGIN, 
    MENU, 
    LEVEL_SELECT, 
    PLAYING, 
    PAUSED, 
    LOADING, 
}

const STATE_NAMES: Dictionary = {
    State.NONE: &"none", 
    State.LOGIN: &"login", 
    State.MENU: &"menu", 
    State.LEVEL_SELECT: &"level_select", 
    State.PLAYING: &"playing", 
    State.PAUSED: &"paused", 
    State.LOADING: &"loading", 
}

signal state_entered(state: State, data: Dictionary)
signal state_exited(state: State)

var _current: State = State.NONE

func get_state() -> State:
    return _current

func get_state_name() -> StringName:
    return STATE_NAMES.get(_current, &"none")

func set_state(new_state: State, data: Dictionary = {}) -> void :
    if _current == new_state:
        return

    state_exited.emit(_current)

    var old_name: StringName = get_state_name()
    _current = new_state
    var new_name: StringName = STATE_NAMES.get(_current, &"none")

    state_entered.emit(_current, data)
    EventBus.game_state_changed.emit(old_name, new_name)
