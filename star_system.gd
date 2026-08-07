class_name StarSystem
extends Resource

## Ein komplettes Sonnensystem samt Stern und Planeten.

@export var system_name: String = ""
@export var seed_value: int = 0

@export var star_type: String = "G"          # Spektralklasse O/B/A/F/G/K/M
@export var star_color: Color = Color.WHITE
@export var star_color_dark: Color = Color.BLACK

@export var map_position: Vector2 = Vector2.ZERO   # Position auf der Universumskarte

@export var planets: Array[Planet] = []
@export var is_bookmarked: bool = false
