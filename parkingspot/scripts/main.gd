extends Node2D

@onready var buttons: Marker2D = $Buttons
var button_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


func _process(delta: float) -> void:
	for button_index in range(0,buttons.get_child_count()-1):
		buttons.get_child(button_index).text = str(button_counts[button_index])


func on_spot_voted(spot_index) -> void:
	button_counts[spot_index] += 1


func _on_spot_0_pressed() -> void:
	on_spot_voted(0)


func _on_spot_1_pressed() -> void:
	on_spot_voted(1)


func _on_spot_2_pressed() -> void:
	on_spot_voted(2)


func _on_spot_3_pressed() -> void:
	on_spot_voted(3)


func _on_spot_4_pressed() -> void:
	on_spot_voted(4)


func _on_spot_5_pressed() -> void:
	on_spot_voted(5)


func _on_spot_6_pressed() -> void:
	on_spot_voted(6)

func _on_spot_7_pressed() -> void:
	on_spot_voted(7)

func _on_spot_8_pressed() -> void:
	on_spot_voted(8)

func _on_spot_9_pressed() -> void:
	on_spot_voted(9)

func _on_spot_10_pressed() -> void:
	on_spot_voted(10)

func _on_spot_11_pressed() -> void:
	on_spot_voted(11)

func _on_spot_12_pressed() -> void:
	on_spot_voted(12)


func _on_spot_13_pressed() -> void:
	on_spot_voted(13)


func _on_spot_14_pressed() -> void:
	on_spot_voted(14)


func _on_spot_15_pressed() -> void:
	on_spot_voted(15)
	
