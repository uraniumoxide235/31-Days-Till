extends Node2D
class_name SystemView

## Zeigt ein einzelnes System: Stern in der Mitte, Planeten aufgereiht.
## Hover = Tooltip mit Namen, Klick = Planet auswaehlen (-> PlanetPanel).

signal planet_hovered(planet_name: String, screen_pos: Vector2)
signal hover_cleared()
signal planet_selected(planet: Planet)

var current_system: StarSystem
var hovered_planet_index: int = -1
var selected_planet_index: int = -1

const STAR_VISUAL_RADIUS := 40.0
const PLANET_SPACING := 90.0
const PLANET_START_X := 160.0

func _ready() -> void:
	# Zentriert das System, da hier (anders als bei der Karte) keine Kamera noetig ist.
	position = get_viewport_rect().size / 2.0

func show_system(system: StarSystem) -> void:
	current_system = system
	hovered_planet_index = -1
	selected_planet_index = -1
	queue_redraw()

func _planet_visual_radius(p: Planet) -> float:
	return clamp(p.radius * 0.6, 8.0, 26.0)

func _planet_position(index: int) -> Vector2:
	return Vector2(PLANET_START_X + index * PLANET_SPACING, 0.0)

func _draw() -> void:
	if current_system == null:
		return

	# Stern
	draw_circle(Vector2.ZERO, STAR_VISUAL_RADIUS, current_system.star_color)
	draw_arc(Vector2.ZERO, STAR_VISUAL_RADIUS + 6.0, 0.0, TAU, 32, current_system.star_color.lightened(0.3), 2.0)

	for i in range(current_system.planets.size()):
		var p: Planet = current_system.planets[i]
		var pos := _planet_position(i)
		var r := _planet_visual_radius(p)

		draw_line(Vector2.ZERO, pos, Color(1, 1, 1, 0.08), 1.0)

		# etwas Farbverlauf: aussen dunklere Kante, innen die Grundfarbe
		draw_circle(pos, r, p.color_dark)
		draw_circle(pos, r * 0.82, p.color)

		if p.has_rings:
			draw_arc(pos, r + 6.0, 0.0, TAU, 32, Color(0.9, 0.85, 0.7, 0.6), 2.0)

		for m in range(p.moons.size()):
			var moon_pos: Vector2 = pos + Vector2(0, r + 12.0 + m * 8.0)
			draw_circle(moon_pos, 2.0, p.moons[m].color)

		if i == selected_planet_index:
			draw_arc(pos, r + 5.0, 0.0, TAU, 24, Color(1, 1, 1), 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if current_system == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_pos := to_local(get_global_mouse_position())
		var idx := _planet_at(local_pos)
		if idx >= 0:
			selected_planet_index = idx
			planet_selected.emit(current_system.planets[idx])
			queue_redraw()
	elif event is InputEventMouseMotion:
		var local_pos := to_local(get_global_mouse_position())
		var idx := _planet_at(local_pos)
		if idx != hovered_planet_index:
			hovered_planet_index = idx
			if idx >= 0:
				planet_hovered.emit(current_system.planets[idx].planet_name, event.position)
			else:
				hover_cleared.emit()

func _planet_at(local_pos: Vector2) -> int:
	for i in range(current_system.planets.size()):
		var p: Planet = current_system.planets[i]
		var pos := _planet_position(i)
		var r := _planet_visual_radius(p) + 4.0
		if local_pos.distance_to(pos) < r:
			return i
	return -1
