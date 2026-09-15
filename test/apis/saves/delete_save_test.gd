extends GdUnitTestSuite

var _saved_offline_mode: bool


func before_test() -> void:
	_saved_offline_mode = Talo.settings.offline_mode
	Talo.settings.offline_mode = true


func after_test() -> void:
	Talo.settings.offline_mode = _saved_offline_mode
	Talo.saves._saves_manager.all_saves = []


func test_delete_save_only_removes_the_target_save() -> void:
	var keep := TaloGameSave.new({ id = 1, name = "keep", content = { }, updatedAt = "" })
	var remove := TaloGameSave.new({ id = 2, name = "remove", content = { }, updatedAt = "" })
	Talo.saves._saves_manager.all_saves = [keep, remove]

	await Talo.saves.delete_save(remove)

	assert_array(Talo.saves.all).contains_exactly([keep])
