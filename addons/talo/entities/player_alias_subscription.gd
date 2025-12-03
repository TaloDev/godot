class_name TaloPlayerAliasSubscription extends RefCounted

enum RelationshipType {
	UNIDIRECTIONAL,
	BIDIRECTIONAL
}

var id: int
var subscriber: TaloPlayerAlias
var subscribed_to: TaloPlayerAlias
var confirmed: bool
var relationship_type: RelationshipType
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	subscriber = TaloPlayerAlias.new(data.subscriber)
	subscribed_to = TaloPlayerAlias.new(data.subscribedTo)
	confirmed = data.confirmed
	relationship_type = RelationshipType.BIDIRECTIONAL if data.relationshipType == "bidirectional" else RelationshipType.UNIDIRECTIONAL
	created_at = data.createdAt
	updated_at = data.updatedAt
