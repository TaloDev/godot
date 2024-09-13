extends Node2D

var entry_scene = preload("res://addons/talo/samples/leaderboards/entry.tscn")

@export var leaderboard_internal_name: String

@onready var leaderboard_name: Label = %LeaderboardName
@onready var entries_container: VBoxContainer = %Entries
@onready var info_label: Label = %InfoLabel
@onready var username: TextEdit = %Username

var _entries_error: bool

func _ready() -> void:
  leaderboard_name.text = leaderboard_name.text.replace("{leaderboard}", leaderboard_internal_name)

  await _load_entries()
  if entries_container.get_child_count() == 0:
    info_label.text = "No entries yet!" if not _entries_error else "Failed loading leaderboard %s. Does it exist?" % [leaderboard_internal_name]
  else:
    info_label.text = "%s entries" % entries_container.get_child_count()

func _create_entry(entry: TaloLeaderboardEntry) -> void:
  var entry_instance = entry_scene.instantiate()
  entry_instance.set_data(entry.position, entry.player_alias.identifier, entry.score)
  entries_container.add_child(entry_instance)

func _build_entries() -> void:
  for child in entries_container.get_children():
    child.queue_free()

  for entry in Talo.leaderboards.get_cached_entries(leaderboard_internal_name):
    _create_entry(entry)

func _load_entries() -> void:
  var page = 0
  var done = false

  while !done:
    var res = await Talo.leaderboards.get_entries(leaderboard_internal_name, page)

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

  var res = await Talo.leaderboards.add_entry(leaderboard_internal_name, score)
  info_label.text = "You scored %s points!%s" % [score, " Your highscore was updated!" if res[1] else ""]

  _build_entries()
