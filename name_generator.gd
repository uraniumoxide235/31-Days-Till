class_name NameGenerator
extends RefCounted

## Rein prozedurale Namensgenerierung, komplett deterministisch ueber den
## uebergebenen RandomNumberGenerator (gleicher Seed = gleicher Name).

const SYSTEM_PREFIXES := [
	"Kep", "Xar", "Vel", "Nyx", "Orn", "Ther", "Zan", "Qor", "Myr", "Als",
	"Bre", "Cyg", "Drak", "Eon", "Fen", "Gor", "Hel", "Ith", "Jor", "Kel",
	"Lun", "Mor", "Nar", "Oph", "Pyx", "Ryn", "Sol", "Tau", "Urs", "Vex"
]

const SYSTEM_SUFFIXES := [
	"ion", "ara", "eth", "os", "ux", "ael", "iri", "und", "ova", "yx",
	"on", "ax", "en", "ir", "ol", "eus", "ith", "ora", "yn", "al"
]

const PLANET_SUFFIXES := [
	"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
	"XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI"
]

const MOON_LETTERS := ["a", "b", "c", "d"]

static func generate_system_name(rng: RandomNumberGenerator) -> String:
	var prefix: String = SYSTEM_PREFIXES[rng.randi() % SYSTEM_PREFIXES.size()]
	var suffix: String = SYSTEM_SUFFIXES[rng.randi() % SYSTEM_SUFFIXES.size()]
	var number: int = rng.randi_range(1, 999)
	return "%s%s-%d" % [prefix, suffix, number]

static func generate_planet_name(system_name: String, index: int) -> String:
	var roman: String = PLANET_SUFFIXES[index] if index < PLANET_SUFFIXES.size() else str(index + 1)
	return "%s %s" % [system_name, roman]

static func generate_moon_name(planet_name: String, index: int) -> String:
	var letter: String = MOON_LETTERS[index] if index < MOON_LETTERS.size() else str(index)
	return "%s %s" % [planet_name, letter]
