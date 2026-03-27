extends GdUnitTestSuite

func test_insert_into_prop_array_adds_value_to_existing_array() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player.insert_into_prop_array("items", "shield")

	assert_array(player.get_prop_array("items")).contains_exactly(["sword", "shield"])

func test_insert_into_prop_array_does_not_add_duplicate_value() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player.insert_into_prop_array("items", "sword")

	assert_array(player.get_prop_array("items")).contains_exactly(["sword"])

func test_insert_into_prop_array_when_array_was_previously_deleted_clears_null_entry_and_inserts_value() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])
	player.delete_prop_array("items")

	player.insert_into_prop_array("items", "potion")

	assert_array(player.get_prop_array("items")).contains_exactly(["potion"])
	var null_entries := player.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	assert_array(null_entries).is_empty()

func test_insert_into_prop_array_with_empty_value_does_nothing() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player.insert_into_prop_array("items", "")

	assert_array(player.get_prop_array("items")).contains_exactly(["sword"])
