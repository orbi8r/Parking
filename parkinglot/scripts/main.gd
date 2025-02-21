extends Node3D

# Vehicle Scene
var vehicle_scene = preload("res://scenes/vehicle.tscn")

# Paths
@onready var paths: Node3D = $paths

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
@export var speed = 10


func _ready() -> void:
	Supabase.auth.connect("signed_in", Callable(self, "_on_signed_in"))
	Supabase.database.connect("updated", Callable(self, "_on_updated"))
	Supabase.auth.sign_in("hariaakash646@gmail.com","loki@1357")
	
	var path_index = 0
	instanciate_vehicle(path_index)


func update():
	var query = SupabaseQuery.new().from("ParkingSpot").update({"status": 0, "votes": 1}).eq("spot_id", "3")
	Supabase.database.query(query)


func _on_updated(result : Array):
	print(result)


func _on_signed_in(user : SupabaseUser):
	print("Signed In as "+str(user))
	update()


func _process(delta: float) -> void:
	progress_vehicles(delta)
	
	# Temporary test for all tracks
	var done_vehicle_index = get_done_vehicle_index()
	if done_vehicle_index != 15 and done_vehicle_index != -1:
		paths.get_child(done_vehicle_index).get_child(0).progress_ratio = 0
		remove_vehicle(done_vehicle_index)
		instanciate_vehicle(done_vehicle_index+1)
		vehicle_positions[done_vehicle_index] = -1


func remove_vehicle(path_index) -> void:
	if paths.get_child(path_index).get_child(0).get_child_count() == 0:
		return
	paths.get_child(path_index).get_child(0).get_child(0).queue_free()


func instanciate_vehicle(path_index) -> void:
	var vehicle = vehicle_scene.instantiate()
	paths.get_child(path_index).get_child(0).add_child(vehicle)
	vehicle_positions[path_index] = 0


func progress_vehicles(delta) -> void:
	for index in range(0,vehicle_positions.size()):
		if vehicle_positions[index] == -1:
			continue
		vehicle_positions[index] += speed * delta
		paths.get_child(index).get_child(0).progress = vehicle_positions[index]
		if vehicle_global_positions[index] != paths.get_child(index).get_child(0).get_child(0).global_position:
			paths.get_child(index).get_child(0).get_child(0).look_at(vehicle_global_positions[index]+vehicle_velocitys[index],Vector3.UP)
			vehicle_velocitys[index] = (vehicle_global_positions[index] - 
				paths.get_child(index).get_child(0).get_child(0).global_position) / delta
			vehicle_global_positions[index] = paths.get_child(index).get_child(0).get_child(0).global_position


func get_done_vehicle_index() -> int: #Temp function
	for index in range(0,vehicle_positions.size()):
		if paths.get_child(index).get_child(0).progress_ratio == 1:
			return index
	return -1
