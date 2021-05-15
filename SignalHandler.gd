extends Node2D

var dialog_is_active = false

var edited_navigation_polygon = false

var player_pos setget set_player_pos

var can_pause = true
var won = false
var lost = false

var boss = false
var boss_defeated = false
var boss_defeated_show_winscreen = false

signal change_level

signal not_lost
signal near_lost
signal very_near_lost

var num_bad_guys = 0
var num_good_guys = 0
var getting_sick = 0

var did_car_cutscene = false

var good_guys_pos = [] setget set_good_guys_pos

var load_prev_as_innocents = false
var level = 0 setget set_level

var difficulty = "hard" setget set_difficulty

var path := "user://data.json"

var default_data := {
	"level" : var2str(0),
	"options" : {
		"difficulty" : "hard",
		"volume" : var2str(1)
	},
	"good_guys_pos" : var2str([]),
	"did_car_cutscene" : var2str(false),
	"player_pos" : var2str(null)
}

var data = { }

func _ready():
	load_json()

func load_json():
	var file = File.new()
	
	if not file.file_exists(path):
		data = default_data.duplicate(true)
		return
	
	file.open(path, file.READ)
	
	var text = file.get_as_text()
	
	data = parse_json(text)
	
	level = str2var(data["level"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(str2var(data["options"]["volume"])))
	good_guys_pos = str2var(data["good_guys_pos"])
	difficulty = str2var(data["options"]["difficulty"])
	did_car_cutscene = str2var(data["did_car_cutscene"])
	player_pos = str2var(data["player_pos"])
	
	file.close()

func save_json():
	var file
	
	file = File.new()
	
	file.open(path, File.WRITE)
	
	file.store_line(to_json(data))
	
	file.close()

func set_player_pos(val):
	player_pos = val
	data["player_pos"] = var2str(val)
	save_json()

func set_level(val):
	level = val
	emit_signal("change_level")
	data["level"] = var2str(val)
	save_json()

func set_volume(val):
	data["options"]["volume"] = var2str(val)
	save_json()

func set_good_guys_pos(val):
	good_guys_pos = val
	data["good_guys_pos"] = var2str(val)
	save_json()

func set_difficulty(val):
	difficulty = val
	for bad_guy in get_tree().get_nodes_in_group("bad_guys"):
		if bad_guy.has_method("change_difficulty"):
			bad_guy.change_difficulty(val)
	data["options"]["difficulty"] = var2str(val)
	save_json()

func change_num_bad_guys(n):
	num_bad_guys += n
	if num_bad_guys == 0 and getting_sick == 0:
		won = true

func change_num_good_guys(n):
	num_good_guys += n
	if boss:
		if num_good_guys == 0:
			lost = true
	else:
		if num_good_guys<(floor((num_good_guys+num_bad_guys)/3)):
			lost = true
		elif num_good_guys<(floor((num_good_guys+num_bad_guys)/3)+3):
			emit_signal("very_near_lost")
		elif num_good_guys<(floor((num_good_guys+num_bad_guys)/3)+5):
			emit_signal("near_lost")
		else:
			emit_signal("not_lost")

func reset_vars():
	can_pause = true
	won = false
	lost = false
	num_bad_guys = 0
	num_good_guys = 0

func clear_memory():
	dialog_is_active = false
	
	edited_navigation_polygon = false
	
	player_pos = null
	
	can_pause = true
	won = false
	lost = false
	
	boss = false
	boss_defeated = false
	boss_defeated_show_winscreen = false

	num_bad_guys = 0
	num_good_guys = 0
	getting_sick = 0

	good_guys_pos = []
	
	level = 0
	
	data = default_data
	save_json()

func revert_to_save():
	num_bad_guys = 0
	num_good_guys = 0
	getting_sick = 0
	
	can_pause = true
	won = false
	lost = false
	
	boss = false
	boss_defeated = false
	boss_defeated_show_winscreen = false
	
	edited_navigation_polygon = false
	
	dialog_is_active = false
