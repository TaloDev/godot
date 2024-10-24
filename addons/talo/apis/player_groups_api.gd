class_name PlayerGroupsAPI extends TaloAPI

func get_group(group_id: String) -> TaloPlayerGroup:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/%s" % group_id)

	match (res.status):
		200:
			return TaloPlayerGroup.new(res.body.group)
		_:
			return null
