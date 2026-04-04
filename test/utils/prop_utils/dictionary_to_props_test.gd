extends GdUnitTestSuite

func test_dictionary_to_props_creates_prop_per_scalar_key() -> void:
	var result := TaloPropUtils.dictionary_to_props({ "color": "red", "size": "large" })

	assert_int(result.size()).is_equal(2)
	assert_str(result.filter(func (p: TaloProp) -> bool: return p.key == "color").front().value).is_equal("red")
	assert_str(result.filter(func (p: TaloProp) -> bool: return p.key == "size").front().value).is_equal("large")

func test_dictionary_to_props_with_array_key_creates_one_prop_per_value() -> void:
	var result := TaloPropUtils.dictionary_to_props({ "items[]": ["sword", "shield"] })

	assert_int(result.size()).is_equal(2)

	var keys := result.map(func (p: TaloProp) -> String: return p.key)
	assert_array(keys).contains_exactly(["items[]", "items[]"])

	var values := result.map(func (p: TaloProp) -> String: return p.value)
	assert_array(values).contains_exactly(["sword", "shield"])

func test_dictionary_to_props_with_mixed_scalar_and_array() -> void:
	var result := TaloPropUtils.dictionary_to_props({ "color": "red", "items[]": ["sword", "shield"] })

	assert_int(result.size()).is_equal(3)

func test_dictionary_to_props_with_null_value_creates_prop_with_null() -> void:
	var result := TaloPropUtils.dictionary_to_props({ "color": null })

	assert_int(result.size()).is_equal(1)
	assert_object(result.front().value).is_null()

func test_dictionary_to_props_with_array_key_but_non_array_value_treats_as_scalar() -> void:
	var result := TaloPropUtils.dictionary_to_props({ "items[]": "sword" })

	assert_int(result.size()).is_equal(1)
	assert_str(result.front().key).is_equal("items[]")
	assert_str(result.front().value).is_equal("sword")
