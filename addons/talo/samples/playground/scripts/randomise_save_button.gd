extends Button

@export var grid: GridContainer

func _on_pressed() -> void:
	for child: LoadableColorRect in grid.get_children():
		child.randomise()
	
	%ResponseLabel.text = "Colours randomised!"
