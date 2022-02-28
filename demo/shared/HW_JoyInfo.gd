extends GridContainer

onready var joy_info: PackedScene = preload("res://demo/shared/JoyName.tscn")

func update_device_count(n: int) -> void:
	$lblJoy_Detected_info.text = "HW JOYPAD " + str(n) + " detected"

func update_joypad_info() -> void:
	get_tree().call_group("JOY_HW_INFO", "queue_free")
	update_device_count(TNTInputEngine._connected_devices_count)
	if (TNTInputEngine._connected_devices_count > 0):
		show()
		for j in range(TNTInputEngine._connected_devices_count):
			var info: GridContainer = joy_info.instance()

			if j == 0:
				info.set_led(true)
				TNTInputEngine.set_active_joy_id(TNTInputEngine.get_device_id(j))
				# warning-ignore:return_value_discarded
				TNTInputEngine.load_and_apply_joy_db(TNTInputEngine.get_active_joy_id())
			else:
				info.set_led(false)

			info.lblName = (TNTInputEngine.get_device_name(TNTInputEngine.get_device_id(j)))
			info.lblID = (TNTInputEngine.get_device_GUID(TNTInputEngine.get_device_id(j)))
			info._device_id = TNTInputEngine.get_device_id(j)

			add_child(info)

	else:
		hide()

