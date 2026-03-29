extends GdUnitTestSuite

func test_serialise_dictionary_with_scalar_values() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "color": "red", "size": "large" })

	assert_array(result).contains_exactly([
		{ key = "color", value = "red" },
		{ key = "size", value = "large" }
	])

func test_serialise_dictionary_with_null_value_keeps_null() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "color": null })

	assert_array(result).contains_exactly([{ key = "color", value = null }])

func test_serialise_dictionary_with_array_key_expands_values() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "items[]": ["sword", "shield"] })

	assert_array(result).contains_exactly([
		{ key = "items[]", value = "sword" },
		{ key = "items[]", value = "shield" }
	])

func test_serialise_dictionary_with_empty_array_produces_null_sentinel() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "items[]": [] })

	assert_array(result).contains_exactly([{ key = "items[]", value = null }])

func test_serialise_dictionary_with_mixed_scalar_and_array() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "color": "red", "items[]": ["sword", "shield"] })

	assert_array(result).contains(
		{ key = "color", value = "red" }
	)
	assert_array(result).contains(
		{ key = "items[]", value = "sword" }
	)
	assert_array(result).contains(
		{ key = "items[]", value = "shield" }
	)
	assert_int(result.size()).is_equal(3)

func test_serialise_dictionary_with_non_string_scalar_converts_to_string() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "count": 42 })

	assert_array(result).contains_exactly([{ key = "count", value = "42" }])

func test_serialise_dictionary_with_array_key_but_non_array_value_treats_as_scalar() -> void:
	var result := TaloPropUtils.serialise_dictionary({ "items[]": "sword" })

	assert_array(result).contains_exactly([{ key = "items[]", value = "sword" }])
