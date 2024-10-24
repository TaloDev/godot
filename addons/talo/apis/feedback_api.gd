class_name FeedbackAPI extends TaloAPI

func get_categories() -> Array:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/categories")

	match (res.status):
		200:
			var categories: Array = res.body.feedbackCategories.map(func (category: Dictionary): return TaloFeedbackCategory.new(category))
			return categories
		_:
			return []

func send(category_internal_name: String, comment: String) -> void:
	if Talo.identity_check() != OK:
		return
	
	await client.make_request(HTTPClient.METHOD_POST, "/categories/%s" % category_internal_name, {
		comment = comment
	})
