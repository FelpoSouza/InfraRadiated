extends ItemData
class_name BatteryItemData


func use_free(player: Node) -> bool:
	print("Bateria utilizada!")

	# Futuramente:
	# player.thermal_vision_battery += 25.0
	player.thermal_vision_battery += 25.0
	if player.thermal_vision_battery > 100.0:
		player.thermal_vision_battery = 100.0
	InventoryManager.use_selected_item()
	return true
