class_name UniverseGenerator
extends RefCounted

## Erzeugt das komplette Universum rein deterministisch aus einem Master-Seed.
## Es wird NICHTS gespeichert - jedes System/jeder Planet/jeder Mond wird bei
## Bedarf aus seinem Index neu berechnet. Gleicher Index -> immer exakt
## dasselbe Ergebnis. Dadurch bleibt der Speicherbedarf bei 10.000 Systemen
## minimal (nur die "Zusammenfassung" fuer die Kartenansicht wird gecacht).

const SYSTEM_COUNT := 10000
const MASTER_SEED := 1234567  # <- aendern fuer ein komplett anderes Universum

const ATMOSPHERE_POOL := [
	"Stickstoff (N2)", "Sauerstoff (O2)", "Kohlendioxid (CO2)", "Methan (CH4)",
	"Wasserstoff (H2)", "Helium (He)", "Ammoniak (NH3)", "Schwefeldioxid (SO2)",
	"Argon (Ar)", "Wasserdampf (H2O)"
]

const SURFACE_POOL := [
	"Silikatgestein", "Eisen", "Nickel", "Kohlenstoff", "Wassereis",
	"Trockeneis (CO2)", "Schwefel", "Basalt", "Granit", "Salzablagerungen"
]

const GAS_CORE_POOL := [
	"Wasserstoff (H2)", "Helium (He)", "Methan (CH4)", "Ammoniak (NH3)", "Gesteinskern"
]

const MOON_POOL := ["Wassereis", "Trockeneis (CO2)", "Silikatgestein", "Staub", "Basalt"]


# ---------------------------------------------------------------------------
# OEFFENTLICHE API
# ---------------------------------------------------------------------------

## Leichtgewichtige Zusammenfassung fuer die Kartenansicht (10.000x schnell aufrufbar).
static func generate_system_summary(index: int) -> Dictionary:
	var rng := _rng_for(index)
	var name := NameGenerator.generate_system_name(rng)
	var star_type := _random_star_type(rng)
	var color := _color_for_star_type(star_type, rng)
	var pos := _map_position(index, rng)
	return {
		"index": index,
		"name": name,
		"star_type": star_type,
		"color": color,
		"position": pos,
	}

## Volles System inkl. aller Planeten und Monde. Wird nur bei Bedarf
## (Klick auf einen Stern) aufgerufen.
static func generate_system(index: int) -> StarSystem:
	var rng := _rng_for(index)

	var sys := StarSystem.new()
	sys.seed_value = rng.seed
	sys.system_name = NameGenerator.generate_system_name(rng)
	sys.star_type = _random_star_type(rng)
	sys.star_color = _color_for_star_type(sys.star_type, rng)
	sys.star_color_dark = sys.star_color.darkened(0.4)
	sys.map_position = _map_position(index, rng)

	var planet_count := rng.randi_range(0, 21)
	var orbit := rng.randf_range(20.0, 40.0)
	var planets: Array[Planet] = []
	for i in range(planet_count):
		var planet := _generate_planet(rng, sys.system_name, i, orbit)
		planets.append(planet)
		orbit += rng.randf_range(15.0, 45.0)
	sys.planets = planets

	return sys


# ---------------------------------------------------------------------------
# INTERN
# ---------------------------------------------------------------------------

static func _rng_for(index: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = MASTER_SEED + index * 7919  # 7919 ist eine Primzahl -> gute Streuung
	return rng

## Verteilt die Systeme spiralgalaxie-artig in der 2D Kartenansicht.
static func _map_position(index: int, rng: RandomNumberGenerator) -> Vector2:
	var arm := index % 4
	var t := float(index) / float(SYSTEM_COUNT)
	var radius := t * 4000.0 + rng.randf_range(-120.0, 120.0)
	var angle := t * TAU * 3.0 + arm * (TAU / 4.0) + rng.randf_range(-0.35, 0.35)
	return Vector2(cos(angle), sin(angle)) * radius

static func _random_star_type(rng: RandomNumberGenerator) -> String:
	# ungefaehr realistische Verteilung, M-Zwerge sind mit Abstand am haeufigsten
	var roll := rng.randf()
	if roll < 0.76:
		return "M"
	elif roll < 0.88:
		return "K"
	elif roll < 0.96:
		return "G"
	elif roll < 0.99:
		return "F"
	elif roll < 0.998:
		return "A"
	elif roll < 0.9995:
		return "B"
	else:
		return "O"

static func _color_for_star_type(star_type: String, rng: RandomNumberGenerator) -> Color:
	var jitter := rng.randf_range(-0.03, 0.03)
	match star_type:
		"O":
			return Color(0.6, 0.7, 1.0 + jitter)
		"B":
			return Color(0.7, 0.8, 1.0)
		"A":
			return Color(0.9, 0.95, 1.0)
		"F":
			return Color(1.0, 1.0, 0.9)
		"G":
			return Color(1.0, 0.95, 0.7)
		"K":
			return Color(1.0, 0.8, 0.5)
		"M":
			return Color(1.0, 0.5 + jitter, 0.4)
	return Color.WHITE

static func _color_for_planet_type(type: int, rng: RandomNumberGenerator) -> Color:
	match type:
		Planet.PlanetType.GAS:
			var hue: float = rng.randf_range(0.05, 0.15) if rng.randf() < 0.5 else rng.randf_range(0.55, 0.65)
			return Color.from_hsv(hue, rng.randf_range(0.35, 0.65), rng.randf_range(0.7, 1.0))
		Planet.PlanetType.ROCK:
			return Color.from_hsv(rng.randf_range(0.02, 0.11), rng.randf_range(0.3, 0.6), rng.randf_range(0.4, 0.75))
		Planet.PlanetType.WATER:
			return Color.from_hsv(rng.randf_range(0.5, 0.62), rng.randf_range(0.5, 0.8), rng.randf_range(0.6, 0.95))
		Planet.PlanetType.ICE:
			return Color.from_hsv(rng.randf_range(0.5, 0.58), rng.randf_range(0.05, 0.25), rng.randf_range(0.85, 1.0))
	return Color.WHITE

static func _generate_planet(rng: RandomNumberGenerator, system_name: String, index: int, orbit_radius: float) -> Planet:
	var p := Planet.new()
	p.seed_value = rng.randi()
	p.planet_name = NameGenerator.generate_planet_name(system_name, index)
	p.orbit_radius = orbit_radius

	var type_roll := rng.randf()
	if type_roll < 0.30:
		p.type = Planet.PlanetType.GAS
	elif type_roll < 0.65:
		p.type = Planet.PlanetType.ROCK
	elif type_roll < 0.85:
		p.type = Planet.PlanetType.ICE
	else:
		p.type = Planet.PlanetType.WATER

	if p.type == Planet.PlanetType.GAS:
		p.radius = rng.randf_range(20.0, 40.0)
	else:
		p.radius = rng.randf_range(6.0, 16.0)

	# 30% Chance auf Atmosphaere
	p.has_atmosphere = rng.randf() < 0.30
	if p.has_atmosphere:
		p.atmosphere_pressure = rng.randf_range(0.01, 50.0)
		p.atmosphere_composition = _random_composition(rng, ATMOSPHERE_POOL, 2, 4)

	if p.type == Planet.PlanetType.GAS:
		p.surface_composition = _random_composition(rng, GAS_CORE_POOL, 2, 3)
	else:
		p.surface_composition = _random_composition(rng, SURFACE_POOL, 2, 5)

	p.has_rings = rng.randf() < 0.15  # rein kosmetisch

	p.color = _color_for_planet_type(p.type, rng)
	p.color_dark = p.color.darkened(0.45)

	var moon_count := rng.randi_range(0, 3)
	var moons: Array[Moon] = []
	for m in range(moon_count):
		moons.append(_generate_moon(rng, p.planet_name, m))
	p.moons = moons

	return p

static func _generate_moon(rng: RandomNumberGenerator, planet_name: String, index: int) -> Moon:
	var m := Moon.new()
	m.seed_value = rng.randi()
	m.moon_name = NameGenerator.generate_moon_name(planet_name, index)
	m.radius = rng.randf_range(2.0, 6.0)
	m.composition = _random_composition(rng, MOON_POOL, 1, 3)
	m.color = Color.from_hsv(rng.randf(), rng.randf_range(0.05, 0.25), rng.randf_range(0.5, 0.85))
	return m

## Waehlt "count"-viele Eintraege ohne Wiederholung aus dem Pool und verteilt
## zufaellige Prozentwerte darauf, die in Summe 100 ergeben.
## z.B. {"Stickstoff (N2)": 71, "Sauerstoff (O2)": 21, "Argon (Ar)": 8}
static func _random_composition(rng: RandomNumberGenerator, pool: Array, min_c: int, max_c: int) -> Dictionary:
	var available: Array = pool.duplicate()
	var count: int = rng.randi_range(min_c, min(max_c, available.size()))

	var chosen: Array = []
	for i in range(count):
		var idx: int = rng.randi_range(0, available.size() - 1)
		chosen.append(available[idx])
		available.remove_at(idx)

	if count == 1:
		return {chosen[0]: 100}

	var cuts: Array = [0]
	for i in range(count - 1):
		cuts.append(rng.randi_range(1, 99))
	cuts.sort()
	cuts.append(100)

	var result := {}
	for i in range(count):
		var pct: int = cuts[i + 1] - cuts[i]
		if pct <= 0:
			pct = 1
		result[chosen[i]] = pct

	return result
