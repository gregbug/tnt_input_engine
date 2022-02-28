extends Node

onready var hud: Node = $HUD/Container/HW_JoyInfo

func _ready() -> void:
	####################################
	# Remove all Godot default actions #
	####################################
#	for acts in InputMap.get_actions():
#		InputMap.erase_action(acts)
	
	################################################
	# adding keyboard actions binding via code.... #
	################################################
	# FOR SCENE 1
	TNTInputEngine.add_key_binding(KEY_UP, TNTInputEngine.ACTION_JOY_UP)
	TNTInputEngine.add_key_binding(KEY_DOWN, TNTInputEngine.ACTION_JOY_DOWN)
	TNTInputEngine.add_key_binding(KEY_LEFT, TNTInputEngine.ACTION_JOY_LEFT)
	TNTInputEngine.add_key_binding(KEY_RIGHT, TNTInputEngine.ACTION_JOY_RIGHT)
	# FOR SCENE 2
	TNTInputEngine.add_key_binding(KEY_1, TNTInputEngine.ACTION_JOY_A)
	TNTInputEngine.add_key_binding(KEY_2, TNTInputEngine.ACTION_JOY_B)
	TNTInputEngine.add_key_binding(KEY_UP, TNTInputEngine.ACTION_LEFTAXIS_UP)
	TNTInputEngine.add_key_binding(KEY_DOWN, TNTInputEngine.ACTION_LEFTAXIS_DOWN)
	TNTInputEngine.add_key_binding(KEY_LEFT, TNTInputEngine.ACTION_LEFTAXIS_LEFT)
	TNTInputEngine.add_key_binding(KEY_RIGHT, TNTInputEngine.ACTION_LEFTAXIS_RIGHT)
	
	#######################################################
	# adding VPAD/JOYPAD for scene 2 binding via code.... #
	#######################################################
	TNTInputEngine.add_joy_binding(TNTInputEngine.joy.JOY_LEFT)
	TNTInputEngine.add_joy_binding(TNTInputEngine.joy.BTN_A)
	TNTInputEngine.add_joy_binding(TNTInputEngine.joy.BTN_B)
	
	hud.update_joypad_info()
	
# warning-ignore:unused_argument
func _on_Button_pressed() -> void:
	SceneChanger.goto_scene("res://demo/scenes/demo_2.tscn")

# warning-ignore:unused_argument
func _on_TNT_Input_Engine_hw_joy_changed(device_id, connected) -> void:
	hud.update_joypad_info()
