extends GridContainer

onready var lblName: String = $lblName.text setget set_joy_name, get_joy_name
onready var lblID: String = $lblID.text setget set_joy_id, get_joy_id

var _device_id: int = -1

func set_joy_name(name: String) -> void:
	$lblName.text = name
	
func get_joy_name() -> String:
	return $lblName.text

func set_joy_id(id: String) -> void:
	$lblID.text = ", "+id
	
func get_joy_id() -> String:
	return $lblID.text
	
func set_led(on: bool) -> void:
	if on:
		$led.color = Color(.34, .75, .30, 1)
	else:
		$led.color = Color(.09, .21, .08, 1)
		
func get_led() -> bool:
	if $led.color == Color(.34, .75, .30, 1):
		return true
	else:
		return false

func _on_btnUse_pressed() -> void:
	get_tree().call_group("JOY_HW_INFO", "set_led", false)
	call_deferred("set_led", true)
	TNTInputEngine.set_active_joy_id(_device_id)

func _on_btnRemap_pressed() -> void:
	TNTInputEngine.open_hw_joy_remap(TNTInputEngine.get_active_joy_id())
