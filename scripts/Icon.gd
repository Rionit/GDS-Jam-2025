extends TextureRect
class_name Icon

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	randomize_icon()

## Changes to [param icon] which can be [String] or [enum Icon.IconEnum]
func change_icon(perk: Perk) -> void:
	texture = perk.texture

func randomize_icon():
	change_icon(PerkMachine.all_perks.pick_random())
