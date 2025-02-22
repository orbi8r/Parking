extends Node3D

# Vehicle Scene
var vehicle_scene = preload("res://scenes/vehicle.tscn")

# Paths
@onready var paths: Node3D = $paths
@onready var phantom_camera_0: PhantomCamera3D = $PhantomCamera0
@onready var phantom_camera_1: PhantomCamera3D = $PhantomCamera1
@onready var phantom_camera_2: PhantomCamera3D = $PhantomCamera2
@onready var phantom_camera_3: PhantomCamera3D = $PhantomCamera3

# Vehicle Variables
var vehicle_positions = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
var vehicle_velocitys = [Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,
	Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,
	Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,
	Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO]
var vehicle_global_positions = [Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,
	Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,
	Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,
	Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO]
var distance_to_cam = [Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO]
var queue_new_vehicle_called = 0
@export var speed = 5
@export var despawner_time = 2500

var button_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var button_status = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var client : RealtimeClient
var channel : RealtimeChannel
var camera_index = 0


func _ready() -> void:
	Supabase.auth.connect("signed_in", Callable(self, "_on_signed_in"))
	Supabase.database.connect("updated", Callable(self, "_on_updated"))
	#Supabase.auth.sign_in("hariaakash646@gmail.com","loki@1357")  #Nah i wont delete this
	
	client = Supabase.realtime.client("https://kezixoocewyodhfolhfu.supabase.co","eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtleml4b29jZXd5b2RoZm9saGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMTY1MjQsImV4cCI6MjA1NTY5MjUyNH0.agKtWS7fFJ88j296ygMmG4BRx3bEZsdPE3RDx4hui0I")
	client.connect("connected", Callable(self, "_on_connected"))
	client.connect_client()
	
	reset_data()
	
	var path_index = 0
	instanciate_vehicle(path_index)


func _on_connected():
	print("connected realtime")
	channel = client.channel("public", "ParkingSpot")
	channel.connect("update", Callable(self, "_on_insert"))
	channel.subscribe()


func _on_insert(old_record : Dictionary, new_record : Dictionary, channel : RealtimeChannel):
	button_counts[new_record["spot_id"]] = new_record["votes"]
	button_status[new_record["spot_id"]] = new_record["status"]


func reset_data():
	print("reset initial data")
	for index in range(0,button_counts.size()):
		button_counts[index] = 0
		update_button_counts(index)
		button_status[index] = 0
		update_button_status(index)


func update_button_status(index) -> void:
	var query = SupabaseQuery.new().from("ParkingSpot").update({"status": button_status[index]}).eq("spot_id", str(index))
	Supabase.database.query(query)


func update_button_counts(index) -> void:
	var query = SupabaseQuery.new().from("ParkingSpot").update({"votes": button_counts[index]}).eq("spot_id", str(index))
	Supabase.database.query(query)


func _on_updated(result : Array):
	print(result)


func _on_signed_in(user : SupabaseUser):
	print("Signed In as "+str(user))


func _process(delta: float) -> void:
	progress_vehicles(delta)
	reset_done_vehicles()
	remove_duplicate_vehicles()
	phantom_switch(camera_index)


func reset_done_vehicles() -> void:
	for index in range(0,vehicle_positions.size()):
		if button_status[index] == 2 and randi_range(0,despawner_time) == 1:
			remove_vehicle(index)


func queue_new_vehicle() -> void:
	if queue_new_vehicle_called < 1:
		return
	queue_new_vehicle_called = -5
	var new_index = button_counts.find(button_counts.max())
	if button_counts.max() == 0:
		for index in range(0,vehicle_positions.size()):
			if button_status[index] != 2:
				new_index = index
				break
	if button_status[new_index] == 2:
		button_counts[new_index] = 0
		new_index = button_counts.find(button_counts.max())
	if button_status[new_index] == 1:
		return
	instanciate_vehicle(new_index)


func remove_duplicate_vehicles() -> void:
	for path_index in range(0,vehicle_positions.size()):
		if paths.get_child(path_index).get_child(0).get_child_count() > 1:
			paths.get_child(path_index).get_child(0).get_child(paths.get_child(path_index).get_child(0).get_child_count()-1).queue_free()


func remove_vehicle(path_index) -> void:
	if paths.get_child(path_index).get_child(0).get_child_count() == 0:
		return
	paths.get_child(path_index).get_child(0).get_child(0).queue_free()
	vehicle_positions[path_index] == -1
	button_status[path_index] = 0
	update_button_status(path_index)


func instanciate_vehicle(path_index) -> void:
	if button_status[path_index] == 1:
		return
	print("going to "+str(path_index))
	var vehicle = vehicle_scene.instantiate()
	paths.get_child(path_index).get_child(0).add_child(vehicle)
	phantom_look_at(path_index)
	vehicle_positions[path_index] = 0
	button_status[path_index] = 1
	update_button_status(path_index)


func progress_vehicles(delta) -> void:
	queue_new_vehicle_called += 1
	for index in range(0,vehicle_positions.size()):
		if vehicle_positions[index] == -1 or paths.get_child(index).get_child(0).get_child_count() == 0:
			continue
		vehicle_positions[index] += speed * delta
		paths.get_child(index).get_child(0).progress = vehicle_positions[index]
		if vehicle_global_positions[index] != paths.get_child(index).get_child(0).get_child(0).global_position:
			paths.get_child(index).get_child(0).get_child(0).look_at(vehicle_global_positions[index]+vehicle_velocitys[index],Vector3.UP)
			vehicle_velocitys[index] = (vehicle_global_positions[index] - 
				paths.get_child(index).get_child(0).get_child(0).global_position) / delta
			vehicle_global_positions[index] = paths.get_child(index).get_child(0).get_child(0).global_position


func phantom_look_at(index) -> void:
	camera_index = index
	phantom_camera_0.look_at_target = paths.get_child(index).get_child(0)
	phantom_camera_1.look_at_target = paths.get_child(index).get_child(0)
	phantom_camera_2.look_at_target = paths.get_child(index).get_child(0)
	phantom_camera_3.look_at_target = paths.get_child(index).get_child(0)


func phantom_switch(index) -> void:
	distance_to_cam = [phantom_camera_0.global_position.distance_squared_to(vehicle_global_positions[index]),
		phantom_camera_1.global_position.distance_squared_to(vehicle_global_positions[index]),
		phantom_camera_2.global_position.distance_squared_to(vehicle_global_positions[index]),
		phantom_camera_3.global_position.distance_squared_to(vehicle_global_positions[index])]
	var min_at = distance_to_cam.find(distance_to_cam.min())
	phantom_camera_0.get_child(0).current = false
	phantom_camera_1.get_child(0).current = false
	phantom_camera_2.get_child(0).current = false
	phantom_camera_3.get_child(0).current = false
	if min_at == 3:
		phantom_camera_3.get_child(0).current = true
	elif min_at == 2:
		phantom_camera_2.get_child(0).current = true
	elif min_at == 1:
		phantom_camera_1.get_child(0).current = true
	else:
		phantom_camera_0.get_child(0).current = true


# Very good coding skillz ahead

func _on_sensor_0_area_exited(_area: Area3D) -> void:
	button_status[0] = 0
	update_button_status(0)


func _on_sensor_1_area_exited(_area: Area3D) -> void:
	button_status[1] = 0
	update_button_status(1)


func _on_sensor_2_area_exited(_area: Area3D) -> void:
	button_status[2] = 0
	update_button_status(2)


func _on_sensor_3_area_exited(_area: Area3D) -> void:
	button_status[3] = 0
	update_button_status(3)


func _on_sensor_4_area_exited(_area: Area3D) -> void:
	button_status[4] = 0
	update_button_status(4)


func _on_sensor_5_area_exited(_area: Area3D) -> void:
	button_status[5] = 0
	update_button_status(5)


func _on_sensor_6_area_exited(_area: Area3D) -> void:
	button_status[6] = 0
	update_button_status(6)


func _on_sensor_7_area_exited(_area: Area3D) -> void:
	button_status[7] = 0
	update_button_status(7)


func _on_sensor_8_area_exited(_area: Area3D) -> void:
	button_status[8] = 0
	update_button_status(8)


func _on_sensor_9_area_exited(_area: Area3D) -> void:
	button_status[9] = 0
	update_button_status(9)


func _on_sensor_10_area_exited(_area: Area3D) -> void:
	button_status[10] = 0
	update_button_status(10)


func _on_sensor_11_area_exited(_area: Area3D) -> void:
	button_status[11] = 0
	update_button_status(11)


func _on_sensor_12_area_exited(_area: Area3D) -> void:
	button_status[12] = 0
	update_button_status(12)


func _on_sensor_13_area_exited(_area: Area3D) -> void:
	button_status[13] = 0
	update_button_status(13)


func _on_sensor_14_area_exited(_area: Area3D) -> void:
	button_status[14] = 0
	update_button_status(14)


func _on_sensor_15_area_exited(_area: Area3D) -> void:
	button_status[15] = 0
	update_button_status(15)


func _on_sensor_0_area_entered(_area: Area3D) -> void:
	button_status[0] = 2
	update_button_status(0)
	queue_new_vehicle()


func _on_sensor_1_area_entered(_area: Area3D) -> void:
	button_status[1] = 2
	update_button_status(1)
	queue_new_vehicle()


func _on_sensor_2_area_entered(_area: Area3D) -> void:
	button_status[2] = 2
	update_button_status(2)
	queue_new_vehicle()


func _on_sensor_3_area_entered(_area: Area3D) -> void:
	button_status[3] = 2
	update_button_status(3)
	queue_new_vehicle()


func _on_sensor_4_area_entered(_area: Area3D) -> void:
	button_status[4] = 2
	update_button_status(4)
	queue_new_vehicle()


func _on_sensor_5_area_entered(_area: Area3D) -> void:
	button_status[5] = 2
	update_button_status(5)
	queue_new_vehicle()


func _on_sensor_6_area_entered(_area: Area3D) -> void:
	button_status[6] = 2
	update_button_status(6)
	queue_new_vehicle()


func _on_sensor_7_area_entered(_area: Area3D) -> void:
	button_status[7] = 2
	update_button_status(7)
	queue_new_vehicle()


func _on_sensor_8_area_entered(_area: Area3D) -> void:
	button_status[8] = 2
	update_button_status(8)
	queue_new_vehicle()


func _on_sensor_9_area_entered(_area: Area3D) -> void:
	button_status[9] = 2
	update_button_status(9)
	queue_new_vehicle()


func _on_sensor_10_area_entered(_area: Area3D) -> void:
	button_status[10] = 2
	update_button_status(10)
	queue_new_vehicle()


func _on_sensor_11_area_entered(_area: Area3D) -> void:
	button_status[11] = 2
	update_button_status(11)
	queue_new_vehicle()


func _on_sensor_12_area_entered(_area: Area3D) -> void:
	button_status[12] = 2
	update_button_status(12)
	queue_new_vehicle()


func _on_sensor_13_area_entered(_area: Area3D) -> void:
	button_status[13] = 2
	update_button_status(13)
	queue_new_vehicle()


func _on_sensor_14_area_entered(_area: Area3D) -> void:
	button_status[14] = 2
	update_button_status(14)
	queue_new_vehicle()


func _on_sensor_15_area_entered(_area: Area3D) -> void:
	button_status[15] = 2
	update_button_status(15)
	queue_new_vehicle()
