extends GdUnitTestSuite

func test_delete_prop_array_array_is_empty_and_sentinel_null_exists_in_props() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
	])

	player.delete_prop_array("items")

	assert_array(player.get_prop_array("items")).is_empty()
	var null_entries := player.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	assert_array(null_entries).has_size(1)

func test_delete_prop_array_when_the_array_does_not_exist_does_nothing() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player.delete_prop_array("other")

	assert_int(player.props.size()).is_equal(1)

func test_delete_prop_array_accepts_key_with_or_without_brackets() -> void:
	var player_a := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])
	var player_b := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	player_a.delete_prop_array("items")
	player_b.delete_prop_array("items[]")

	var null_a := player_a.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	var null_b := player_b.props.filter(func (p: TaloProp) -> bool: return p.key == "items[]" && p.value == null)
	assert_array(null_a).has_size(1)
	assert_array(null_b).has_size(1)
