extends TaloLoadable

@export var username = "generate_identifier"

@onready var character_body: CharacterBody2D = get_parent()

var stars := 0
var spawn_level := "starting_zone"
var spawn_point := Vector2.ZERO

@onready var levels: Dictionary[String, Resource] = {
	"starting_zone" = load("res://addons/talo/samples/saves/starting_zone.tscn"),
	"green_zone" = load("res://addons/talo/samples/saves/scenes/green_zone.tscn"),
	"blue_zone" = load("res://addons/talo/samples/saves/scenes/blue_zone.tscn")
}

func _toggle_scene_visibility(visible: bool):
	character_body.get_parent().visible = visible

func _ready():
	_toggle_scene_visibility(false)
	%Stars.visible = false

	Talo.players.identified.connect(_on_identified)
	Talo.players.identify("username", username)

	id = username
	# register the loadable
	super()

func _on_identified(_player: TaloPlayer):
	var saves := await Talo.saves.get_saves()
	if saves.is_empty():
		await Talo.saves.create_save("save")

	await Talo.saves.choose_save(Talo.saves.all.front())

func register_fields():
	register_field("stars", stars)
	register_field("spawn_point", spawn_point)
	register_field("spawn_level", spawn_level)

func on_loaded(data: Dictionary):
	update_stars(data.get("stars", 0))

	spawn_point = data.get("spawn_point", Vector2.ZERO)
	character_body.position = spawn_point
	character_body.destination = spawn_point

	spawn_level = data.get("spawn_level", "starting_zone")
	if get_tree().current_scene.scene_file_path.ends_with("%s.tscn" % spawn_level):
		# the correct level is loaded so we won't be changing scenes
		_toggle_scene_visibility(true)
	else:
		# change to the correct level scene
		call_deferred("change_scene", spawn_level)

func on_star_pickup():
	update_stars(stars + 1)
	spawn_point = character_body.position
	await Talo.saves.update_current_save()

func update_stars(new_stars: int):
	stars = new_stars
	if stars > 0:
		%Stars.visible = true
		%Stars.text = "%s star%s" % [stars, "s" if stars > 1 else ""]

func on_portal_entered(new_level: String, new_spawn_point: Vector2):
	spawn_level = new_level
	spawn_point = new_spawn_point
	await Talo.saves.update_current_save()
	call_deferred("change_scene", new_level)

func change_scene(to_level: String):
	get_tree().change_scene_to_packed(levels[to_level])
