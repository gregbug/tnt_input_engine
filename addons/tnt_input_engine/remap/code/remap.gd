#
#	       ###### ##   ## ######
#	         ##   #### ##   ##
#	         ##   ## ####   ##
#	         ##   ##   ##   ##
#
#       	 Input Engine 1.00
#
#  by Gianluca D'Angelo copyright (c) 2021 
#            all right reserved.                     
#                                         
# - v1.00 release - 01/03/2021 -          
#

extends Node2D

onready var landscape: PackedScene = preload("res://addons/tnt_input_engine/remap/JoyMap_Landscape.tscn")
onready var portrait: PackedScene = preload("res://addons/tnt_input_engine/remap/JoyMap_Portrait.tscn")

var _back_scene: String = ""

func _ready() -> void:
	if TNTInputEngine._screen_is_landscape(get_viewport_rect().size):
		var landscape_map: Node2D = landscape.instance()
		landscape_map._back_scene = _back_scene
		add_child(landscape_map)
	else:
		var portrait_map: Node2D = portrait.instance()
		portrait_map._back_scene = _back_scene
		add_child(portrait_map)
	
