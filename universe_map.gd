extends Node2D
class_name UniverseMap

## Zeigt alle 10.000 Sternsysteme als Punkte an. Ziehen = Kamera verschieben,
## Mausrad = Zoom, Hover = Tooltip mit Name, Klick = System auswaehlen.

signal system_hovered(system_name: String, screen_pos: Vector2)
signal hover_cleared()
signal system_selected(index: int)

@onready var camera: Camera2D = $Camera2D

var systems_summary: Array = []
var bookmarked: Dictionary = {}   # index -> true
var selected_index: int = -1
var hovered_index: int = -1

var _dragging := false
var _drag_start := Vector2.ZERO
var _cam_start := Vector2.ZERO

const HOVER_RADIUS_PX := 14.0

func _ready() -> void:
	_generate_all_summaries()
	queue_redraw()

func _generate_all_summaries() -> void:
	systems_summary.clear()
	systems_summary.resize(UniverseGenerator.SYSTEM_COUNT)
	for i in range(UniverseGenerator.SYSTEM_COUNT):
		systems_summary[i] = UniverseGenerator.generate_system_summary(i)

func _star_visual_radius(star_type: String) -> float:
	match star_type:
		"O": return 7.0
		"B": return 6.0
		"A": return 5.0
		"F": return 4.5
		"G": return 4.0
		"K": return 3.5
		"M": return 3.0
	return 3.0

func _draw() -> void:
	for s in systems_summary:
		var pos: Vector2 = s["position"]
		var col: Color = s["color"]
		var r := _star_visual_radius(s["star_type"])
		draw_circle(pos, r, col)

	for idx in bookmarked.keys():
		var s = systems_summary[idx]
		draw_arc(s["position"], _star_visual_radius(s["star_type"]) + 4.0, 0.0, TAU, 24, Color(1.0, 0.85, 0.2), 1.5)

	if selected_index >= 0:
		var s = systems_summary[selected_index]
		draw_arc(s["position"], _star_visual_radius(s["star_type"]) + 7.0, 0.0, TAU, 32, Color(1, 1, 1), 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_start = event.position
				_cam_start = camera.position
			else:
				_dragging = false
				if event.position.distance_to(_drag_start) < 4.0:
					_try_select(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(0.9, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1.1, event.position)
	elif event is InputEventMouseMotion:
		if _dragging:
			var delta: Vector2 = (event.position - _drag_start) / camera.zoom
			camera.position = _cam_start - delta
			if hovered_index != -1:
				hovered_index = -1
				hover_cleared.emit()
		else:
			_try_hover(event.position)

func _zoom(factor: float, mouse_screen_pos: Vector2) -> void:
	var before := get_global_mouse_position()
	camera.zoom *= factor
	camera.zoom = camera.zoom.clamp(Vector2(0.05, 0.05), Vector2(4.0, 4.0))
	var after := get_global_mouse_position()
	camera.position += before - after

func _world_pos_from_screen(screen_pos: Vector2) -> Vector2:
	return camera.position + (screen_pos - get_viewport_rect().size / 2.0) / camera.zoom

func _nearest_system(world_pos: Vector2) -> int:
	var best_idx := -1
	var best_dist: float = HOVER_RADIUS_PX / camera.zoom.x
	for i in range(systems_summary.size()):
		var d: float = world_pos.distance_to(systems_summary[i]["position"])
		if d < best_dist:
			best_dist = d
			best_idx = i
	return best_idx

func _try_hover(screen_pos: Vector2) -> void:
	var world_pos := _world_pos_from_screen(screen_pos)
	var idx := _nearest_system(world_pos)
	if idx != hovered_index:
		hovered_index = idx
		if idx >= 0:
			system_hovered.emit(systems_summary[idx]["name"], screen_pos)
		else:
			hover_cleared.emit()

func _try_select(screen_pos: Vector2) -> void:
	var world_pos := _world_pos_from_screen(screen_pos)
	var idx := _nearest_system(world_pos)
	if idx >= 0:
		selected_index = idx
		system_selected.emit(idx)
		queue_redraw()

func toggle_bookmark(index: int) -> void:
	if index < 0:
		return
	if bookmarked.has(index):
		bookmarked.erase(index)
	else:
		bookmarked[index] = true
	queue_redraw()

func is_bookmarked(index: int) -> bool:
	return bookmarked.has(index)
