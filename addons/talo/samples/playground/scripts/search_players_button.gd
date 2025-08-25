extends Button

@onready var line_edit: LineEdit = %SearchLineEdit

func _on_pressed() -> void:
	var query = line_edit.text.strip_edges()
	if query.is_empty():
		%ResponseLabel.text = "Please enter a query e.g. a player ID, alias identifier or prop value"
		return

	%ResponseLabel.text = "Searching for: %s..." % [query]
	var search_page := await Talo.players.search(query)
	if search_page.count == 0:
		%ResponseLabel.text = "No players found"
		return

	%ResponseLabel.text = "Found %s results" % search_page.count
