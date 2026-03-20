extends GdUnitTestSuite

func test_remove_from_prop_array_removes_matching_value() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
	])

	player.remove_from_prop_array("items", "sword")

	assert_array(player.get_prop_array("items")).contains_exactly(["shield"])

func test_remove_from_prop_array_when_last_item_removed_array_is_empty_and_sentinel_null_exists_in_props() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player.remove_from_prop_array("items", "sword")

	assert_array(player.get_prop_array("items")).is_empty()
	var null_entries := player.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	assert_array(null_entries).has_size(1)

func test_remove_from_prop_array_when_array_is_already_deleted_remains_deleted() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])
	player.delete_prop_array("items")

	player.remove_from_prop_array("items", "sword")

	var null_entries := player.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	assert_array(null_entries).has_size(1)

func test_remove_from_prop_array_when_value_does_not_exist_does_nothing() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
	])

	player.remove_from_prop_array("items", "potion")

	assert_array(player.get_prop_array("items")).contains_exactly(["sword", "shield"])

func test_remove_from_prop_array_when_array_is_already_deleted_does_nothing() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])
	player.delete_prop_array("items")
	var props_before: Array[TaloProp] = player.props.duplicate()

	player.remove_from_prop_array("items", "sword")

	assert_int(player.props.size()).is_equal(props_before.size())
