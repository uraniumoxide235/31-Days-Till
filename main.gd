extends Node

@onready var universe_map: UniverseMap = $UniverseMap
@onready var system_view: SystemView = $SystemView
@onready var planet_panel: PlanetPanel = $UI/PlanetPanel
@onready var tooltip: Label = $UI/Tooltip
@onready var bookmark_button: Button = $UI/BookmarkButton
@onready var back_button: Button = $UI/BackButton

var current_system_index: int = -1
var current_system: StarSystem

func _ready() -> void:
	system_view.visible = false
	back_button.visible = false
	bookmark_button.visible = false
	planet_panel.visible = false
	tooltip.visible = false

	universe_map.system_hovered.connect(_on_hover)
	universe_map.hover_cleared.connect(_on_hover_cleared)
	universe_map.system_selected.connect(_on_star_selected)

	system_view.planet_hovered.connect(_on_hover)
	system_view.hover_cleared.connect(_on_hover_cleared)
	system_view.planet_selected.connect(_on_planet_selected)

	bookmark_button.pressed.connect(_on_bookmark_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_hover(name: String, screen_pos: Vector2) -> void:
	tooltip.text = name
	tooltip.position = screen_pos + Vector2(14, 14)
	tooltip.visible = true

func _on_hover_cleared() -> void:
	tooltip.visible = false

func _on_star_selected(index: int) -> void:
	current_system_index = index
	current_system = UniverseGenerator.generate_system(index)
	system_view.show_system(current_system)

	universe_map.visible = false
	system_view.visible = true
	back_button.visible = true
	bookmark_button.visible = true
	planet_panel.visible = false
	tooltip.visible = false

	_update_bookmark_button()

func _on_back_pressed() -> void:
	system_view.visible = false
	universe_map.visible = true
	back_button.visible = false
	bookmark_button.visible = false
	planet_panel.visible = false
	tooltip.visible = false

func _on_bookmark_pressed() -> void:
	universe_map.toggle_bookmark(current_system_index)
	_update_bookmark_button()

func _update_bookmark_button() -> void:
	if universe_map.is_bookmarked(current_system_index):
		bookmark_button.text = "★ Gemerkt"
	else:
		bookmark_button.text = "☆ Merken"

func _on_planet_selected(planet: Planet) -> void:
	planet_panel.visible = true
	planet_panel.show_planet(planet)
