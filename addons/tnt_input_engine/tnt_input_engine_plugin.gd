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

tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton(
		"TNTInputEngine", 
		"res://addons/tnt_input_engine/code/global_class/tnt_input_engine_global.gd"
	)
	
func _exit_tree() -> void:
	remove_autoload_singleton("TNTInputEngine")
