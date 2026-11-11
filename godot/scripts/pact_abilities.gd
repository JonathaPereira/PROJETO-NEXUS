extends RefCounted
## A completed personal journey unlocks one campaign alternative per hero.
static var recipes: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/pact-abilities.json"))

static func recipe(hero: String, action: String) -> Dictionary:
 var value: Dictionary=recipes.get(hero,{})
 return value if value.get("action")==action else {}

static func build(hero: Dictionary, action: String) -> Dictionary:
 var value:=recipe(hero.id,action)
 if value.is_empty():return {}
 var result: Dictionary=hero[action].duplicate(true)
 for key in value.get("remove",[]):result.erase(key)
 result.merge(value.patch,true)
 result.name=value.name
 result.description=value.description+" Custo: %d EN."%result.cost
 result.trainingLabel="Pacto pessoal"
 return result
