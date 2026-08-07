class_name Planet
extends Resource

## Ein einzelner Planet innerhalb eines Sonnensystems.

enum PlanetType { GAS, ROCK, WATER, ICE }

@export var planet_name: String = ""
@export var type: PlanetType = PlanetType.ROCK

@export var has_atmosphere: bool = false
@export var atmosphere_pressure: float = 0.0        # in bar, nur relevant wenn has_atmosphere
@export var atmosphere_composition: Dictionary = {}   # Gas -> Prozent, nur wenn has_atmosphere

@export var surface_composition: Dictionary = {}      # Material -> Prozent (Gestein/Eis/Wasser/Gaskern)

@export var has_rings: bool = false                   # rein kosmetisch
@export var moons: Array[Moon] = []

@export var color: Color = Color.WHITE
@export var color_dark: Color = Color.BLACK

@export var orbit_radius: float = 100.0                # Abstand zum Stern (nur fuers Layout)
@export var radius: float = 10.0                        # rein visuelle Groesse
@export var seed_value: int = 0

func type_name() -> String:
	match type:
		PlanetType.GAS:
			return "Gasriese"
		PlanetType.ROCK:
			return "Gesteinsplanet"
		PlanetType.WATER:
			return "Wasserplanet"
		PlanetType.ICE:
			return "Eisplanet"
	return "Unbekannt"
