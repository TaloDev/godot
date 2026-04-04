extends GdUnitTestSuite

func test_props_to_dictionary_with_scalar_props() -> void:
	var props: Array[TaloProp] = [TaloProp.new("color", "red"), TaloProp.new("size", "large")]

	var result := TaloPropUtils.props_to_dictionary(props)

	assert_str(result["color"]).is_equal("red")
	assert_str(result["size"]).is_equal("large")

func test_props_to_dictionary_with_null_value_stores_null() -> void:
	var props: Array[TaloProp] = [TaloProp.new("color", null)]

	var result := TaloPropUtils.props_to_dictionary(props)

	assert_object(result["color"]).is_null()

func test_props_to_dictionary_with_array_props_collects_values_under_array_key() -> void:
	var props: Array[TaloProp] = [TaloProp.new("items[]", "sword"), TaloProp.new("items[]", "shield")]

	var result := TaloPropUtils.props_to_dictionary(props)

	assert_array(result["items[]"]).contains_exactly(["sword", "shield"])

func test_props_to_dictionary_with_array_props_skips_null_sentinel_values() -> void:
	var props: Array[TaloProp] = [TaloProp.new("items[]", null)]

	var result := TaloPropUtils.props_to_dictionary(props)

	assert_array(result["items[]"]).is_empty()

func test_props_to_dictionary_with_mixed_scalar_and_array_props() -> void:
	var props: Array[TaloProp] = [
		TaloProp.new("color", "red"),
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
	]

	var result := TaloPropUtils.props_to_dictionary(props)

	assert_str(result["color"]).is_equal("red")
	assert_array(result["items[]"]).contains_exactly(["sword", "shield"])
