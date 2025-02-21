extends Control

# Buttons
@onready var spot_5: Button = $AspectContainer/VBoxContainer/Hbox0/Spot5
@onready var spot_6: Button = $AspectContainer/VBoxContainer/Hbox0/Spot6
@onready var spot_7: Button = $AspectContainer/VBoxContainer/Hbox0/Spot7
@onready var spot_8: Button = $AspectContainer/VBoxContainer/Hbox0/Spot8
@onready var spot_9: Button = $AspectContainer/VBoxContainer/Hbox0/Spot9
@onready var spot_10: Button = $AspectContainer/VBoxContainer/Hbox0/Spot10
@onready var spot_11: Button = $AspectContainer/VBoxContainer/Hbox0/Spot11
@onready var spot_12: Button = $AspectContainer/VBoxContainer/Hbox0/Spot12
@onready var spot_13: Button = $AspectContainer/VBoxContainer/Hbox0/Spot13
@onready var spot_4: Button = $AspectContainer/VBoxContainer/Hbox1/Spot4
@onready var spot_3: Button = $AspectContainer/VBoxContainer/Hbox2/Spot3
@onready var spot_2: Button = $AspectContainer/VBoxContainer/Hbox3/Spot2
@onready var spot_14: Button = $AspectContainer/VBoxContainer/Hbox3/Spot14
@onready var spot_15: Button = $AspectContainer/VBoxContainer/Hbox3/Spot15
@onready var spot_1: Button = $AspectContainer/VBoxContainer/Hbox4/Spot1
@onready var spot_0: Button = $AspectContainer/VBoxContainer/Hbox5/Spot0

var button_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var button_status = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var buttons = []
var client : RealtimeClient
var channel : RealtimeChannel
var fetched_initial_data = 0

func _ready() -> void:
	client = Supabase.realtime.client("https://kezixoocewyodhfolhfu.supabase.co","eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtleml4b29jZXd5b2RoZm9saGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMTY1MjQsImV4cCI6MjA1NTY5MjUyNH0.agKtWS7fFJ88j296ygMmG4BRx3bEZsdPE3RDx4hui0I")
	client.connect("connected", Callable(self, "_on_connected"))
	client.connect_client()
	Supabase.database.connect("updated", Callable(self, "_on_updated"))
	Supabase.database.connect("selected", Callable(self, "_on_selected"))
	buttons = [spot_0,spot_1,spot_2,spot_3,spot_4,spot_5,spot_6,spot_7,spot_8,spot_9,spot_10,spot_11,spot_12,spot_13,spot_14,spot_15]
	var query = SupabaseQuery.new().from("ParkingSpot").select()
	Supabase.database.query(query)


func _process(delta: float) -> void:
	for button_index in range(0,buttons.size()):
		buttons[button_index].text = str(button_counts[button_index])
		if button_status[button_index] == 0:
			set_stylebox_color(buttons[button_index], Color.GREEN)
		elif button_status[button_index] == 1:
			set_stylebox_color(buttons[button_index], Color.YELLOW)
		else:
			set_stylebox_color(buttons[button_index], Color.RED)


func set_stylebox_color(button: Button, color: Color):
	var stylebox_theme: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_theme.bg_color = color
	stylebox_theme.border_color = color
	button.add_theme_stylebox_override("normal", stylebox_theme)


func _on_connected():
	print("connected realtime")
	channel = client.channel("public", "ParkingSpot")
	channel.connect("update", Callable(self, "_on_insert"))
	channel.subscribe()


func _on_insert(old_record : Dictionary, new_record : Dictionary, channel : RealtimeChannel):
	button_counts[new_record["spot_id"]] = new_record["votes"]
	button_status[new_record["spot_id"]] = new_record["status"]


func _on_updated(result : Array):
	print(result)


func _on_selected(result : Array):
	fetched_initial_data = 1
	print("fetched initial data")
	for index in range(0,button_counts.size()):
		button_counts[result[index]["spot_id"]] = result[index]["votes"]
		button_status[result[index]["spot_id"]] = result[index]["status"]


func select_button_counts() -> void:
	pass


func on_spot_voted(spot_index) -> void:
	if fetched_initial_data == 0:
		return
	if button_status[spot_index] != 0:
		return
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
	
