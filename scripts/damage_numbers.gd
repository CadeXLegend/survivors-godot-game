class_name DamageNumbers
extends Resource

@export var labelSettings: LabelSettings
@export var normalColour: Color
@export var criticalColour: Color
@export var noDamageColour: Color
@export var outlineColour: Color
@export var outlineSize: int = 18
@export var fontSize: int = 18

@export var firstPropertyToAnimate: String = "position:y"
@export var easeInAnimationPositionOffset: int = 128
@export var easeInDuration: float = 0.25
@export var easeOutDuration: float = 0.5
@export var easeOutDelay: float = 0.25

@export var secondPropertyToAnimate: String = "scale"

func display_number(value: float, position: Vector2, sceneRoot: Node, isCritical: bool = false):
	var number = Label.new()
	number.global_position = position + Vector2.DOWN
	number.text = str(value as int)
	number.z_index = 128

	labelSettings.font_color = noDamageColour if value == 0.0 else \
		 criticalColour if isCritical else normalColour

	number.label_settings = labelSettings
	
	sceneRoot.call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = sceneRoot.create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, firstPropertyToAnimate, number.position.y - easeInAnimationPositionOffset, easeInDuration
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, firstPropertyToAnimate, number.position.y, easeOutDuration
	).set_ease(Tween.EASE_OUT).set_delay(easeOutDelay)
	tween.tween_property(
		number, secondPropertyToAnimate, Vector2.ZERO, easeInDuration
	).set_ease(Tween.EASE_IN).set_delay(easeOutDuration)

	await tween.finished
	number.queue_free()
