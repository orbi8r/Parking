extends Control

# Buttons
@onready var spot_5: Button = $MarginContainer/VBoxContainer/Hbox0/Spot5
@onready var spot_6: Button = $MarginContainer/VBoxContainer/Hbox0/Spot6
@onready var spot_7: Button = $MarginContainer/VBoxContainer/Hbox0/Spot7
@onready var spot_8: Button = $MarginContainer/VBoxContainer/Hbox0/Spot8
@onready var spot_9: Button = $MarginContainer/VBoxContainer/Hbox0/Spot9
@onready var spot_10: Button = $MarginContainer/VBoxContainer/Hbox0/Spot10
@onready var spot_11: Button = $MarginContainer/VBoxContainer/Hbox0/Spot11
@onready var spot_12: Button = $MarginContainer/VBoxContainer/Hbox0/Spot12
@onready var spot_13: Button = $MarginContainer/VBoxContainer/Hbox0/Spot13
@onready var spot_4: Button = $MarginContainer/VBoxContainer/Hbox1/Spot4
@onready var spot_3: Button = $MarginContainer/VBoxContainer/Hbox2/Spot3
@onready var spot_2: Button = $MarginContainer/VBoxContainer/Hbox3/Spot2
@onready var spot_14: Button = $MarginContainer/VBoxContainer/Hbox3/Spot14
@onready var spot_15: Button = $MarginContainer/VBoxContainer/Hbox3/Spot15
@onready var spot_1: Button = $MarginContainer/VBoxContainer/Hbox4/Spot1
@onready var spot_0: Button = $MarginContainer/VBoxContainer/Hbox5/Spot0

var button_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var buttons = []

func _ready() -> void:
	Supabase.database.connect("updated", Callable(self, "_on_updated"))
	buttons = [spot_0,spot_1,spot_2,spot_3,spot_4,spot_5,spot_6,spot_7,spot_8,spot_9,spot_10,spot_11,spot_12,spot_13,spot_14,spot_15]


func _process(delta: float) -> void:
	for button_index in range(0,buttons.size()):
		buttons[button_index].text = str(button_counts[button_index])


func _on_updated(result : Array):
	print(result)


func select_button_counts() -> void:
	pass


func on_spot_voted(spot_index) -> void:
	button_counts[spot_index] += 1
	var query = SupabaseQuery.new().from("ParkingSpot").update({"votes": button_counts[spot_index]}).eq("spot_id", str(spot_index))
	Supabase.database.query(query)


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
	
