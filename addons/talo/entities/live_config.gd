class_name TaloLiveConfig extends Node

var props: Array[TaloProp] = []

func _init(props: Array):
	self.props.assign(props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

func get_prop(key: String, fallback: String) -> String:
	var filtered = props.filter(func (prop: TaloProp): return prop.key == key)
	return fallback if filtered.is_empty() else filtered.front()
