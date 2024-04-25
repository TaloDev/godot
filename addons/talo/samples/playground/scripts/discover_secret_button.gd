extends Button

@export var stat_name: String

func _on_pressed() -> void:
	Talo.stats.track(stat_name)
