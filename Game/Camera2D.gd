tool
extends Camera2D

#Variables
export(NodePath) var target_node_path setget set_target_node_path #A path to that target node
var target_node : Node = null #The target the sprite will head towards
export(int) var x_bound = 1500
export(int) var y_bound = 1600

onready var tw = $Tween

func _ready() -> void:
	#Get Target Node
	update_target_node()
	
	#Reposition
	if target_node != null:
		global_position = target_node.global_position


func set_target_node_path(val) -> void:
	target_node_path = val
	
	#Update
	update_target_node()


func update_target_node() -> void:
	#Get Target Node
	var node = get_node_or_null(target_node_path)
	if node != null:
		target_node = node


func _physics_process(delta):
	if target_node != null:
		position.x = clamp(target_node.global_position.x, -x_bound, x_bound)
		position.y = clamp(target_node.global_position.y, -y_bound, y_bound)
		
func screen_shake():
	$Tween.interpolate_property(self, "offset_v", null, 0.5, 0.1)
	$Tween.interpolate_property(self, "offset_v", 0.5, 0, 1.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT, 0.1)
	$Tween.start()
