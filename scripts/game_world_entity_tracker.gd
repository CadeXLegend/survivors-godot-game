extends Node

#func player() -> Player:
	#return get_tree().get_first_node_in_group("Players")

func enemies() -> Array[Node]:
	return get_tree().get_nodes_in_group("Mobs")

func world_grids() -> Array[Node]:
	return get_tree().get_nodes_in_group("HexGrid")

func find_nearest_enemy(ref: Node) -> Node:
	var nearest = null
	var min_distance = INF
	for body in enemies():
		var distance = ref.global_position.distance_to(body.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = body
	return nearest
