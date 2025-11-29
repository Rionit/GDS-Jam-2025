extends TextureRect
class_name Icon

const BANAN_ICON = preload("uid://qxm3vv4a7ob")
const CARD_CLUBS_ICON = preload("uid://cyi5r6jx5y8le")
const CARD_DIAMONDS_ICON = preload("uid://cr5fvdcs5mkh2")
const CARD_HEARTS_ICON = preload("uid://p01trqhhw02s")
const CARD_SPADES_ICON = preload("uid://vp5a5tg86pnk")
const CHERRY_ICON = preload("uid://cgmli0o3q0em3")
const CLOVER_ICON = preload("uid://ddi2dnagmltx0")
const DIAMOND_ICON = preload("uid://do5j8cs2582jy")
const MELOUN_ICON = preload("uid://2lcvwxho8fsv")
const SEVEN_ICON = preload("uid://c6j0qqq10bo1h")

enum IconEnum { BANAN, CLUBS, DIAMONDS, HEARTS, SPADES, CHERRY, CLOVER, DIAMOND, MELOUN, SEVEN }

@export var current_icon: IconEnum = IconEnum.BANAN

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	randomize_icon()

## Converts [enum Icon.IconEnum] → [String]
func icon_to_string(icon: IconEnum) -> String:
	match icon:
		IconEnum.BANAN: return "Banan"
		IconEnum.CLUBS: return "Clubs"
		IconEnum.DIAMONDS: return "Diamonds"
		IconEnum.HEARTS: return "Hearts"
		IconEnum.SPADES: return "Spades"
		IconEnum.CHERRY: return "Cherry"
		IconEnum.CLOVER: return "Clover"
		IconEnum.DIAMOND: return "Diamond"
		IconEnum.MELOUN: return "Meloun"
		IconEnum.SEVEN: return "Seven"
		_: return "Unknown"


# Converts string → enum
func string_to_icon(icon: String) -> IconEnum:
	match icon:
		"Banan": return IconEnum.BANAN
		"Clubs": return IconEnum.CLUBS
		"Diamonds": return IconEnum.DIAMONDS
		"Hearts": return IconEnum.HEARTS
		"Spades": return IconEnum.SPADES
		"Cherry": return IconEnum.CHERRY
		"Clover": return IconEnum.CLOVER
		"Diamond": return IconEnum.DIAMOND
		"Meloun": return IconEnum.MELOUN
		"Seven": return IconEnum.SEVEN
		_: return current_icon  # fallback to last valid one

## Returns preloaded texture
func get_icon_texture(icon: IconEnum) -> Texture:
	match icon:
		IconEnum.BANAN: return BANAN_ICON
		IconEnum.CLUBS: return CARD_CLUBS_ICON
		IconEnum.DIAMONDS: return CARD_DIAMONDS_ICON
		IconEnum.HEARTS: return CARD_HEARTS_ICON
		IconEnum.SPADES: return CARD_SPADES_ICON
		IconEnum.CHERRY: return CHERRY_ICON
		IconEnum.CLOVER: return CLOVER_ICON
		IconEnum.DIAMOND: return DIAMOND_ICON
		IconEnum.MELOUN: return MELOUN_ICON
		IconEnum.SEVEN: return SEVEN_ICON
		_: return null


## Changes to [param icon] which can be [String] or [enum Icon.IconEnum]
func change_icon(icon) -> void:
	current_icon = icon
	texture = get_icon_texture(current_icon)
	


func randomize_icon():
	change_icon(IconEnum.values().pick_random())
