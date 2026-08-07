class_name Moon
extends Resource

## Ein Mond eines Planeten.

@export var moon_name: String = ""
@export var composition: Dictionary = {}  # Material -> Prozent (int), summiert ~100
@export var color: Color = Color.WHITE
@export var radius: float = 4.0           # rein visuelle Groesse
@export var seed_value: int = 0
