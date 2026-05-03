extends Control

@onready var bar_one: TextureRect = $BarOne
@onready var bar_two: TextureRect = $BarTwo
@onready var anim: AnimationPlayer = $MeterAnim

@export var damage_popup_scene: PackedScene
@export var damage_value: int = 12

var frozen := false

var perfect_min := 260.0
var perfect_max := 290.0

var good_min := 200.0
var good_max := 340.0

func _ready() -> void:
	bar_two.visible = false
	anim.play("slide_loop")

func _process(_delta: float) -> void:
	bar_two.global_position = bar_one.global_position

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		trigger_hit()

func trigger_hit() -> void:
	if frozen:
		return

	frozen = true

	var x := bar_one.position.x

	anim.speed_scale = 0.0
	bar_two.visible = true

	await start_flick()

	if x >= perfect_min and x <= perfect_max:
		print("PERFECT 🔥")
	elif x >= good_min and x <= good_max:
		print("GOOD 👍")
	else:
		print("MISS 💀")

	spawn_damage_number(damage_value)
	hide_meter()

func start_flick() -> void:
	for i in range(5):
		bar_one.visible = not bar_one.visible
		bar_two.visible = not bar_two.visible
		await get_tree().create_timer(0.03).timeout

	bar_one.visible = true
	bar_two.visible = false

func spawn_damage_number(amount: int) -> void:
	if damage_popup_scene == null:
		return

	var popup := damage_popup_scene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = bar_one.global_position + Vector2(0, 70)
	popup.setup(amount)

func hide_meter() -> void:
	visible = false
