class_name LoadableColorRect extends TaloLoadable

var color_rect: ColorRect

func _ready() -> void:
	super()
	color_rect = get_child(1)

func register_fields() -> void:
	register_field("r", color_rect.color.r)
	register_field("g", color_rect.color.g)
	register_field("b", color_rect.color.b)

func on_loaded(data: Dictionary) -> void:
	color_rect.color = Color(data["r"], data["g"], data["b"])

func randomise() -> void:
	color_rect.color = Color(randf(), randf(), randf())
