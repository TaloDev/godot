class_name PlayerGroupsAPI extends TaloAPI
## An interface for communicating with the Talo Player Groups API.
##
## This API is used to fetch info about group memberships. Player groups are used to segment players into groups based on filter criteria.
##
## @tutorial: https://docs.trytalo.com/docs/godot/groups

## Get the members of a group. If the group is public (as set in the dashboard), the members will be returned. If the group is private, only a membership count will be returned. Members are paginated and a page number can be specified.
func get_group(group_id: String, page: int = 0) -> GroupPage:
	var res := await client.make_request(HTTPClient.METHOD_GET, "/%s?page=%s" % [group_id, page])

	match res.status:
		200:
			var group = TaloPlayerGroup.new(res.body.group)
			var pagination = res.body.membersPagination
			return GroupPage.new(group, pagination.count, pagination.itemsPerPage, pagination.isLastPage)
		_:
			return null

class GroupPage:
	var group: TaloPlayerGroup
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(group: TaloPlayerGroup, count: int, items_per_page: int, is_last_page: bool) -> void:
		self.group = group
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page
