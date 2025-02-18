extends Node2D

var entry_scene = preload("res://addons/talo/samples/leaderboards/entry.tscn")

@export var leaderboard_internal_name: String
@export var include_archived: bool = false

@onready var leaderboard_name: Label = %LeaderboardName
@onready var entries_container: VBoxContainer = %Entries
@onready var info_label: Label = %InfoLabel
@onready var username: TextEdit = %Username
@onready var filter_button: Button = %Filter

var _entries_error: bool
var _filter: String = "All"
var _filter_idx: int = 0

func _ready() -> void:
	leaderboard_name.text = leaderboard_name.text.replace("{leaderboard}", leaderboard_internal_name)
	await _load_entries()
	_set_entry_count()

func _set_entry_count():
	if entries_container.get_child_count() == 0:
		info_label.text = "No entries yet!" if not _entries_error else "Failed loading leaderboard %s. Does it exist?" % leaderboard_internal_name
	else:
		info_label.text = "%s entries" % entries_container.get_child_count()
		if _filter != "All":
			info_label.text += " (%s team)" % _filter

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry_scene.instantiate()
	entry_instance.set_data(entry)
	entries_container.add_child(entry_instance)

func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries = Talo.leaderboards.get_cached_entries(leaderboard_internal_name)
	if _filter != "All":
		entries = entries.filter(func(entry: TaloLeaderboardEntry): return entry.get_prop("team", "") == _filter)

	for entry in entries:
		entry.position = entries.find(entry)
		_create_entry(entry)

func _load_entries() -> void:
	var page = 0
	var done = false

	while !done:
		var res = await Talo.leaderboards.get_entries(leaderboard_internal_name, page, -1, include_archived)

		if res.size() == 0:
			_entries_error = true
			return

		var entries = res[0]
		var last_page = res[2]

		if last_page:
			done = true
		else:
			page += 1

	_build_entries()

func _on_submit_pressed() -> void:
	await Talo.players.identify("username", username.text)
	var score = RandomNumberGenerator.new().randi_range(0, 100)
	var team = "Blue" if RandomNumberGenerator.new().randi_range(0, 1) == 0 else "Red"

	var res = await Talo.leaderboards.add_entry(leaderboard_internal_name, score, {team = team})
	info_label.text = "You scored %s points for the %s team!%s" % [score, team, " Your highscore was updated!" if res[1] else ""]

	_build_entries()

func _get_next_filter(idx: int) -> String:
	return ["All", "Blue", "Red"][idx % 3]

func _on_filter_pressed() -> void:
	_filter_idx += 1
	_filter = _get_next_filter(_filter_idx)

	info_label.text = "Filtering on %s" % filter_button.text.to_lower()
	filter_button.text = "%s team scores" % _get_next_filter(_filter_idx + 1)

	_build_entries()
