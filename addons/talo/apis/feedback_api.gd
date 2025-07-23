class_name FeedbackAPI extends TaloAPI
## An interface for communicating with the Talo Feedback API.
##
## This API is used to submit feedback across different categories from your players.
##
## @tutorial: https://docs.trytalo.com/docs/godot/feedback

## Get a list of feedback categories that are available for players to submit feedback.
func get_categories() -> Array[TaloFeedbackCategory]:
	var res := await client.make_request(HTTPClient.METHOD_GET, "/categories")

	match res.status:
		200:
			var categories: Array[TaloFeedbackCategory] = []
			categories.assign(res.body.feedbackCategories.map(func (category: Dictionary): return TaloFeedbackCategory.new(category)))
			return categories
		_:
			return []

## Submit feedback for a specific category. Optionally add props for extra context.
func send(category_internal_name: String, comment: String, props: Dictionary[String, String] = {}) -> void:
	if Talo.identity_check() != OK:
		return

	var props_to_send := props \
		.keys() \
		.map(func (key: String): return { key = key, value = str(props[key]) })
	
	await client.make_request(HTTPClient.METHOD_POST, "/categories/%s" % category_internal_name, {
		comment = comment,
		props = props_to_send
	})
