extends Label

func _ready() -> void:
	Talo.game_config.live_config_loaded.connect(_on_live_config_loaded)

func _on_live_config_loaded(config: TaloLiveConfig):
	text = JSON.stringify(config.props.map(func (prop: TaloProp): return prop.to_dictionary()))
