class_name TaloChannelStorageProp extends TaloProp

var created_by_alias: TaloPlayerAlias
var last_updated_by_alias: TaloPlayerAlias
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	super(data.key, data.value)

	# these fields are only missing in the new_from_prop path
	if data.has("createdBy"):
		created_by_alias = TaloPlayerAlias.new(data.createdBy)
	if data.has("lastUpdatedBy"):
		last_updated_by_alias = TaloPlayerAlias.new(data.lastUpdatedBy)

	created_at = data.createdAt
	updated_at = data.updatedAt

static func new_from_prop(source: TaloChannelStorageProp, value: String) -> TaloChannelStorageProp:
	var expanded := TaloChannelStorageProp.new({
		key = source.key,
		value = value,
		createdAt = source.created_at,
		updatedAt = source.updated_at
	})
	expanded.created_by_alias = source.created_by_alias
	expanded.last_updated_by_alias = source.last_updated_by_alias

	return expanded
