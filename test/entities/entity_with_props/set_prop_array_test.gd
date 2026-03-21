extends GdUnitTestSuite

func test_set_prop_array_with_new_key_adds_all_values() -> void:
	var player := TaloEntityWithProps.new([])

	player.set_prop_array("items", ["sword", "shield"])

	assert_array(player.get_prop_array("items")).contains_exactly(["sword", "shield"])

func test_set_prop_array_deduplicates_values() -> void:
	var player := TaloEntityWithProps.new([])

	player.set_prop_array("items", ["sword", "sword", "shield"])

	assert_array(player.get_prop_array("items")).contains_exactly(["sword", "shield"])

func test_set_prop_array_with_all_empty_values_does_nothing() -> void:
	var player := TaloEntityWithProps.new([])

	player.set_prop_array("items", ["", ""])

	assert_array(player.get_prop_array("items")).is_empty()

func test_set_prop_array_on_existing_populated_array_replaces_old_values() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
	])

	player.set_prop_array("items", ["potion"])

	assert_array(player.get_prop_array("items")).contains_exactly(["potion"])

func test_set_prop_array_with_empty_collection_does_nothing() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player.set_prop_array("items", [])

	assert_array(player.get_prop_array("items")).contains_exactly(["sword"])

func test_set_prop_array_when_array_was_previously_deleted_clears_null_entry_and_sets_new_values() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])
	player.delete_prop_array("items")

	player.set_prop_array("items", ["potion"])

	assert_array(player.get_prop_array("items")).contains_exactly(["potion"])
	var null_entries := player.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	assert_array(null_entries).is_empty()
