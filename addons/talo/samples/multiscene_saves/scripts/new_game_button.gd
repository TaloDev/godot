extends Button

func _ready():
	pressed.connect(func (): Talo.saves.unload_current_save())
