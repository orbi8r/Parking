@tool
extends Node

const ENVIRONMENT_VARIABLES : String = "supabase/config"

var auth : SupabaseAuth 
var database : SupabaseDatabase
var realtime : SupabaseRealtime
var storage : SupabaseStorage

var debug: bool = false

var config : Dictionary = {
	"supabaseUrl": "https://kezixoocewyodhfolhfu.supabase.co",
	"supabaseKey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtleml4b29jZXd5b2RoZm9saGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMTY1MjQsImV4cCI6MjA1NTY5MjUyNH0.agKtWS7fFJ88j296ygMmG4BRx3bEZsdPE3RDx4hui0I"
}

var header : PackedStringArray = [
	"Content-Type: application/json",
	"Accept: application/json"
]

func _ready() -> void:
	load_config()
	load_nodes()

# Load all config settings from ProjectSettings
func load_config() -> void:
	if config.supabaseKey != "" and config.supabaseUrl != "":
		pass
	else:    
		var env = ConfigFile.new()
		var err = env.load("res://addons/supabase/.env")
		if err == OK:
			for key in config.keys(): 
				var value : String = env.get_value(ENVIRONMENT_VARIABLES, key, "")
				if value == "":
					printerr("%s has not a valid value." % key)
				else:
					config[key] = value
		else:
			printerr("Unable to read .env file at path 'res://.env'")
	header.append("apikey: %s"%[config.supabaseKey])

func load_nodes() -> void:
	auth = SupabaseAuth.new(config, header)
	database = SupabaseDatabase.new(config, header)
	realtime = SupabaseRealtime.new(config)
	storage = SupabaseStorage.new(config)
	add_child(auth)
	add_child(database)
	add_child(realtime)
	add_child(storage)

func set_debug(debugging: bool) -> void:
	debug = debugging

func _print_debug(msg: String) -> void:
	if debug: print_debug(msg)
