extends CharacterBody2D

# =============================================
#  SOUL SETTINGS
# =============================================
@export var base_speed: float = 280.0
@export var focus_speed_multiplier: float = 0.5
@export var invincibility_duration: float = 0.6

# =============================================
#  INTERNAL STATE
# =============================================
var is_invincible: bool = false
var current_speed: float

@onready var invincible_timer: Timer

# =============================================
#  READY
# =============================================
func _ready() -> void:
	current_speed = base_speed
	position = Vector2.ZERO   # Keep local position stable inside BattleBox
	
	# Setup timer
	invincible_timer = Timer.new()
	invincible_timer.one_shot = true
	invincible_timer.wait_time = invincibility_duration
	invincible_timer.timeout.connect(_on_invincible_end)
	add_child(invincible_timer)

# =============================================
#  MOVEMENT
# =============================================
func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Focus mode (Hold Shift)
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = base_speed * focus_speed_multiplier
	else:
		current_speed = base_speed

	velocity = direction * current_speed
	move_and_slide()

# =============================================
#  DAMAGE
# =============================================
func take_damage(amount: int) -> void:
	if is_invincible:
		return

	is_invincible = true

	if SavM and "data" in SavM:
		SavM.data.hp = max(0, SavM.data.hp - amount)

	_flash_damage()
	invincible_timer.start()

func _flash_damage() -> void:
	modulate = Color(1.0, 0.4, 0.4, 0.7)
	await get_tree().create_timer(invincibility_duration).timeout
	modulate = Color.WHITE

func _on_invincible_end() -> void:
	is_invincible = false
