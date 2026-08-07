extends PanelContainer
class_name PlanetPanel

## Zeigt alle Details eines Planeten: Typ, Atmosphaere, Zusammensetzung,
## Ringe und die Monde (mit eigener Zusammensetzung per Klick).

@onready var title_label: Label = $VBox/Title
@onready var type_label: Label = $VBox/Type
@onready var atmosphere_label: Label = $VBox/Atmosphere
@onready var atmosphere_list: VBoxContainer = $VBox/AtmosphereList
@onready var surface_list: VBoxContainer = $VBox/SurfaceList
@onready var rings_label: Label = $VBox/Rings
@onready var moons_container: VBoxContainer = $VBox/MoonsList
@onready var moon_detail_label: RichTextLabel = $VBox/MoonDetail

var current_planet: Planet

func show_planet(planet: Planet) -> void:
	current_planet = planet
	title_label.text = planet.planet_name
	type_label.text = "Typ: %s" % planet.type_name()

	if planet.has_atmosphere:
		atmosphere_label.text = "Atmosphäre: Ja (%.2f bar)" % planet.atmosphere_pressure
	else:
		atmosphere_label.text = "Atmosphäre: Nein"

	_fill_composition_list(atmosphere_list, planet.atmosphere_composition, "Keine Atmosphäre")
	_fill_composition_list(surface_list, planet.surface_composition, "Keine Daten")

	rings_label.text = "Ringe: %s" % ("Ja" if planet.has_rings else "Nein")

	_fill_moons(planet)
	moon_detail_label.text = ""

func _fill_composition_list(container: VBoxContainer, composition: Dictionary, empty_text: String) -> void:
	for child in container.get_children():
		child.queue_free()
	if composition.is_empty():
		var lbl := Label.new()
		lbl.text = empty_text
		container.add_child(lbl)
		return
	for key in composition.keys():
		var lbl := Label.new()
		lbl.text = "%s: %d%%" % [key, composition[key]]
		container.add_child(lbl)

func _fill_moons(planet: Planet) -> void:
	for child in moons_container.get_children():
		child.queue_free()
	if planet.moons.is_empty():
		var lbl := Label.new()
		lbl.text = "Keine Monde"
		moons_container.add_child(lbl)
		return
	for m in planet.moons:
		var btn := Button.new()
		btn.text = m.moon_name
		btn.pressed.connect(_on_moon_pressed.bind(m))
		moons_container.add_child(btn)

func _on_moon_pressed(moon: Moon) -> void:
	var text := "[b]%s[/b]\n" % moon.moon_name
	for key in moon.composition.keys():
		text += "%s: %d%%\n" % [key, moon.composition[key]]
	moon_detail_label.text = text
