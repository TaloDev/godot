extends Button

func _ready() -> void:
	Talo.game_config.live_config_loaded.connect(_on_live_config_loaded)
	Talo.game_config.live_config_updated.connect(_on_live_config_updated)

func _on_pressed() -> void:
	Talo.game_config.get_live_config()

func _stringify_props(props: Array[TaloProp]) -> String:
	return JSON.stringify(props.map(func (prop: TaloProp): return prop.to_dictionary()))

func _on_live_config_loaded(config: TaloLiveConfig):
	%ResponseLabel.text = "Live config loaded: %s" % _stringify_props(config.props)

func _on_live_config_updated(live_config: TaloLiveConfig) -> void:
	%ResponseLabel.text = "Live config updated: %s" % _stringify_props(live_config.props)
