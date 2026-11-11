extends RefCounted
## A victory records the three unordered pairs from the starting trio.
const REQUIRED_VICTORIES := 3
const OPENING_ENERGY := 2

static func _key(left: String, right: String) -> String:
	return left + "|" + right if left < right else right + "|" + left

static func wins(ledger: Dictionary, left: String, right: String) -> int:
	return int(ledger.get(_key(left,right),0))

static func record(ledger: Dictionary, trio: Array) -> void:
	for i in range(trio.size()):
		for j in range(i+1,trio.size()):
			var key := _key(trio[i],trio[j])
			ledger[key] = mini(REQUIRED_VICTORIES,int(ledger.get(key,0))+1)

static func energy(ledger: Dictionary, trio: Array, hero: String) -> int:
	if not hero in trio: return 0
	var bonus := 0
	for partner in trio:
		if partner != hero and wins(ledger,hero,partner) >= REQUIRED_VICTORIES: bonus += OPENING_ENERGY
	return bonus

static func valid(ledger: Variant, active: Array, victories: int) -> bool:
	if not ledger is Dictionary or ledger.size() > active.size()*(active.size()-1)/2.0: return false
	var total := 0
	var participation := {}
	for key in ledger:
		if not key is String: return false
		var pair: PackedStringArray = key.split("|")
		if pair.size() != 2 or pair[0] not in active or pair[1] not in active or pair[0] >= pair[1]: return false
		var value: Variant = ledger[key]
		if not (value is int or value is float) or not is_finite(float(value)) or value < 1 or value > mini(REQUIRED_VICTORIES,victories) or value != floor(float(value)): return false
		total += int(value)
		for hero in pair:
			participation[hero] = int(participation.get(hero,0))+int(value)
			if participation[hero] > victories*2: return false
	return total <= victories*3
