extends Node2D

# =====================================================
#  spear.gd
#  Attach to: spear (Node2D root of spear.tscn)
#
#  is_blue = false → normal spear, always damages on hit
#  is_blue = true  → blue spear, SAFE if soul is still
#
#  Set via: spear.set_meta("is_blue", true/false) before add_child
#  Or directly: spear.is_blue = true
# =====================================================

var is_blue : bool = false
var damage  : int  = 4

@onready var area        : Area2D   = $Area2D
@onready var normal_spr  : Sprite2D = $Area2D/spear_normal
@onready var blue_spr    : Sprite2D = $Area2D/blue_spear


func _ready() -> void:
	# Read is_blue from metadata if set before _ready fires
	if has_meta("is_blue"):
		is_blue = get_meta("is_blue")

	# ✅ Nearest filter on spear sprites too — consistent pixel art look
	normal_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	blue_spr.texture_filter   = CanvasItem.TEXTURE_FILTER_NEAREST

	normal_spr.visible = not is_blue
	blue_spr.visible   = is_blue

	# Expose damage via metadata so Area2D detection in Soul.gd also works
	area.set_meta("damage", damage)

	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not (body.is_in_group("soul") or body is CharacterBody2D):
		return

	if is_blue:
		# Blue spear — only hurts if soul is moving
		var vel : Vector2 = body.velocity if "velocity" in body else Vector2.ZERO
		if vel.length() > 5.0:
			_deal_damage()
		# Still = safe, no damage, no queue_free — spear passes through
	else:
		_deal_damage()


func _deal_damage() -> void:
	var manager := _find_battle_manager()
	if manager and manager.has_method("on_soul_hit"):
		manager.on_soul_hit(damage)
	queue_free()


# ✅ FIX: walk up the tree — works regardless of scene structure
func _find_battle_manager() -> Node:
	var node = get_parent()
	while node:
		if node.has_method("on_soul_hit"):
			return node
		node = node.get_parent()
	return null
