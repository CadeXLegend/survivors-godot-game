class_name OptionGUI
extends Area2D

@export var optionText: OptionText

func update_text(title: String, description: String) -> void:
	optionText.title.text = title
	optionText.description.text = description
