class_name IPoolable extends RefCounted



signal returned_to_pool
signal acquired_from_pool

func reset_state() -> void :
    push_warning("IPoolable.reset_state() should be overridden in subclass")

func on_acquired_from_pool() -> void :
    pass

func on_returned_to_pool() -> void :
    pass
