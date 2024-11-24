class_name PlayerGroupsAPI extends TaloAPI
## An interface for communicating with the Talo Player Groups API.
##
## This API is used to fetch info about group memberships. Player groups are used to segment players into groups based on filter criteria.
##
## @tutorial: https://docs.trytalo.com/docs/godot/groups

## Get the members of a group. If the group is public (as set in the dashboard), the members will be returned. If the group is private, only a membership count will be returned.
func get_group(group_id: String) -> TaloPlayerGroup:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/%s" % group_id)

	match (res.status):
		200:
			return TaloPlayerGroup.new(res.body.group)
		_:
			return null
