extends Node3D

# Vehicle Models
@onready var models: Node3D = $models


func _ready() -> void:
	randomize_model()


func _process(_delta: float) -> void:
	pass


func randomize_model() -> void:
	# Hides all children
	for model in models.get_children():
		model.hide()
	# Makes a Random Child visible
	models.get_child(randi_range(0,models.get_child_count()-1)).show()
