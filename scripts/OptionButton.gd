extends OptionButton
enum WorldGenerationTypes {
	Simple,
	Complex
}

var worldtypes = ["Simple", "Complex"]

func _ready():
	var i = 0
	for type in worldtypes:
		add_item(type, i)
		i += 1



func _on_OptionButton_item_selected(index):
	print(index)
	# todo mattf make this actually change something in the world gen
	
