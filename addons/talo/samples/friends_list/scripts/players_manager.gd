class_name FriendsListPlayersManager extends RefCounted

signal players_updated()

var _online_aliases: Dictionary[int, TaloPlayerAlias] = {}

func get_online_aliases() -> Array[TaloPlayerAlias]:
	# exclude the current player
	return _online_aliases.values().filter(
		func (alias: TaloPlayerAlias):
			return alias.id != Talo.current_alias.id
	)

func handle_presence_changed(presence: TaloPlayerPresence) -> void:
	var presence_alias := presence.player_alias
	if presence.online and presence.custom_status == FriendsListSample.lookingForFriendsStatus:
		_online_aliases.set(presence_alias.id, presence_alias)
	else:
		_online_aliases.erase(presence_alias.id)

	players_updated.emit()
