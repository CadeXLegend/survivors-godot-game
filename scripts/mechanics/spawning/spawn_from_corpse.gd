#extends AnimatedSprite2D
#
#@onready var skeleton = preload("res://entities/npcs/skeleton.tscn")
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if(body is not Player):
		#return
	#
	#queue_free()
	#
	#var skelliesInGroup = get_tree().get_nodes_in_group("skellies")
	#if skelliesInGroup.size() >= 5:
		#return
	#
	#var skelly: Summoned_Skeleton = skeleton.instantiate()
	#get_tree().current_scene.call_deferred("add_child", skelly)
	#skelly.add_to_group("skellies")
	#skelly.global_position = global_position
	#skelly.is_ready.connect(await set_skelly_stats(skelly, frame + 1))
#
#func set_skelly_stats(skelly: Summoned_Skeleton, modifier: int):
	#await get_tree().create_timer(0).timeout
	#var health = skelly.health
	#var newHp = health.current * modifier
	#health.increase_max(newHp)
	#health.set_to(newHp)
