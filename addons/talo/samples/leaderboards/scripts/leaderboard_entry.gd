extends Label

func _set_pos(pos: int) -> void:
  text = text.replace("{pos}", str(pos + 1))

func _set_username(username: String) -> void:
  text = text.replace("{username}", username)

func _set_score(score: int) -> void:
  text = text.replace("{score}", str(int(score)))

func set_data(pos: int, username: String, score: int) -> void:
  _set_pos(pos)
  _set_username(username)
  _set_score(score)
